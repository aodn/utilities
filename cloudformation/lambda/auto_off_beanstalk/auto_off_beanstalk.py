import logging
import boto3

# setup simple logging for INFO
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# define the connection
client = boto3.client('elasticbeanstalk')


def handler(event, context):
    response_de = client.describe_environments(IncludeDeleted=False)
    logger.debug('Beanstalk Environments: ' + str(response_de))

    for env in response_de['Environments']:

        if not is_excluded(env):
            logger.info("TERMINATING {0} ({1})".format(env['EnvironmentName'], env['Status']))
            ###############
            terminate(env)
            ###############
        else:
            logger.info("EXCLUDING {0} ({1})".format(env['EnvironmentName'], env['Status']))


def is_excluded(env):
    tags = client.list_tags_for_resource(ResourceArn=env['EnvironmentArn'])
    for tag in tags['ResourceTags']:
        if "AutoOff" in tag['Key'] and "False" in tag['Value']:
            return True

    if env['EnvironmentName'].endswith('-prod'):
        return True

    if env['Status'] not in ('Updating', 'Ready'):
        return True

    return False


def terminate(env):
    terminating_env = client.terminate_environment(
        EnvironmentId=env['EnvironmentId'],
        EnvironmentName=env['EnvironmentName'],
        TerminateResources=True,
        ForceTerminate=True
    )
    logger.debug('ApplicationName: ' + terminating_env['ApplicationName'])
    logger.debug('EnvironmentName: ' + terminating_env['EnvironmentName'])
    logger.debug('EnvironmentId: ' + terminating_env['EnvironmentId'])
    logger.debug('Status: ' + terminating_env['Status'])


if __name__ == "__main__":
    logging.basicConfig()
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    handler(None,None)


