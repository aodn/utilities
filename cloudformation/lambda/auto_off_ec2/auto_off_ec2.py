import boto3
import logging

# setup simple logging for INFO
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# define the connection
ec2 = boto3.resource('ec2')


def handler(event, context):

    # Use the filter() method of the instances collection to retrieve
    # all running EC2 instances.
    filters = [
        {
            'Name': 'instance-state-name',
            'Values': ['running']
        }
    ]

    # filter the instances
    instances = ec2.instances.filter(Filters=filters)
    stop_instances = set()
    prod_instances = {instance.id if prod_instance(instance) else stop_instances.add(instance.id) for instance in
                      instances}

    logger.debug("All Instances")
    all_instances = prod_instances.union(stop_instances)
    logger.debug(len(all_instances))
    logger.debug(all_instances)

    logger.debug("Production Instances")
    logger.debug(len(prod_instances))
    logger.debug(prod_instances)

    logger.debug("Stopping Instances")
    logger.debug(len(stop_instances))
    logger.debug(stop_instances)

    lambdaReport = []

    if len(stop_instances) > 0:

        # perform the shutdown
        lambdaReport.append("Shutting down EC2 instances")

        for instanceid in stop_instances:
            i = ec2.Instance(instanceid)

            objDict = {
                "id": i.instance_id,
                "dns": i.public_dns_name,
                "launch_time": i.launch_time,
                "tagName": getTag(i.tags, "Name")
            }
            lambdaReport.append("Removing Instance Id:{id}".format(**objDict))
            envStr = "  Dns:{dns}\n  Launch-Time:{launch_time}\n  Tag-Name:{tagName}\n".format(**objDict)

            if getTag(i.tags, "aws:cloudformation:stack-name"):
                envStr += "  CloudFormationName: {0}\n".format(getTag(i.tags, "aws:cloudformation:stack-name"))

            if getTag(i.tags, "ebprep:environment-class"):
                envStr += "  EbprepEnv: {0}\n".format(getTag(i.tags, "ebprep:environment-class"))

            if getTag(i.tags, "elasticbeanstalk:environment-name"):
                envStr += "  Elasticbeanstalk-env-name: {0}\n".format(getTag(i.tags, "elasticbeanstalk:environment-name"))

            lambdaReport.append(envStr)

            #######################
            # REMOVE THE INSTANCE #
            i.stop()
            #######################

    else:
        lambdaReport.append("No EC2 instances removed")

    logger.info("\n".join(lambdaReport))
    return lambdaReport


def getTag(tags, keyString):
    if tags is not None:
        for tag in tags:
            if keyString in tag['Key']:
                return tag['Value']
    return None

def prod_instance(instance):
    if instance.tags is not None:
        for tag in instance.tags:
            logger.debug(tag)
            if "Name" in tag['Key'] and "-aws-syd" in tag['Value']:
                return True
            elif "elasticbeanstalk" in tag['Key']:
                return True
            elif "AutoOff" in tag['Key'] and "False" in tag['Value']:
                return True
        return False
