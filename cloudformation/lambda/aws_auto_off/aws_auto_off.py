import boto3
import botocore
import os

# CONSTANTS
active_stack_statuses = ['CREATE_IN_PROGRESS', 'CREATE_COMPLETE', 'DELETE_FAILED',
                         'UPDATE_IN_PROGRESS', 'UPDATE_COMPLETE_CLEANUP_IN_PROGRESS', 'UPDATE_COMPLETE',
                         'UPDATE_ROLLBACK_IN_PROGRESS', 'UPDATE_ROLLBACK_COMPLETE']

protected_stack_names = ['aws-wps-edge', 'aws-wps-sandbox', 'aws-auto-off', 'aws-wps-rc', 'aws-wps-systest',
                         'aws-wps-prod']


# FUNCTIONS
def getTagValue(tagList, keyString):
    if tagList is not None:
        for currentTag in tagList:
            if currentTag['Key'] == keyString:
                return currentTag['Value']
    return None


def is_beanstalk_protected(tags):
    for tag in tags:
        if tag['Key'] == "AutoOff" and tag['Value'] == "False":
            print('    * Tagged with AutoOff=False.  Will not delete.')
            return True

    if getTagValue(tags, 'Name').endswith('-prod'):
        print('    * Production stack!  Will not delete.')
        return True

    return False


def terminate_beanstalk_environment(env, client):

    try:
        terminating_env = client.terminate_environment(
            EnvironmentId=env['EnvironmentId'],
            EnvironmentName=env['EnvironmentName'],
            TerminateResources=True,
            ForceTerminate=True
        )
        print('    TERMINATE BEANSTALK ENVIRONMENT : EnvironmentName: ' + terminating_env['EnvironmentName'] +
              ', ApplicationName: ' + terminating_env + ['ApplicationName'] +
              ', EnvironmentId: ' + terminating_env['EnvironmentId'] +
              ',Status: ' + terminating_env['Status'])
    except botocore.exceptions.ClientError as e:
        error = e.response['Error']
        error_code = error['Code']
        message = error['Message']
        print('    *!  Exception while trying to terminate beanstalk environment: ErrorCode=' + error_code + ', Message=' + message)


def is_ec2_instance_protected(tags):
    if getTagValue(tags, 'AutoOff') == 'False':
        print('    * Tagged with AutoOff=False.  Will not delete.')
        return True

    if getTagValue(tags, 'aws:cloudformation:stack-id'):
        print('    * Instance part of a stack (StackName=' + getTagValue(tags, 'aws:cloudformation:stack-name') + '). Will not delete.')
        return True

    if getTagValue(tags, 'elasticbeanstalk:environment-id'):
        print('    * Instance part of a beanstalk environment (EnvironmentName=' + getTagValue(tags, 'elasticbeanstalk:environment-name') + '). Will not delete.')
        return True

    if tags is not None:
        for tag in tags:
            print(tag)
            if "Name" in tag['Key'] and "-aws-syd" in tag['Value']:
                return True
            elif "elasticbeanstalk" in tag['Key']:
                return True
            elif "AutoOff" in tag['Key'] and "False" in tag['Value']:
                return True
    return False


def terminate_ec2_instance(instance, ec2_client):
    #  Stop EC2 instance
    try:
        print('    STOPPING EC2 INSTANCE : ' + instance['InstanceId'])
        ec2_client.instances.filter(InstanceIds=instance['InstanceId']).stop()
    except botocore.exceptions.ClientError as e:
        error = e.response['Error']
        error_code = error['Code']
        message = error['Message']
        print('    *!  Exception while trying to terminate/stop EC2 instance: ErrorCode=' + error_code + ', Message=' + message)

def is_cloudformation_stack_protected(stack):
    stack_tags = stack['Tags']

    if getTagValue(stack_tags, 'AutoOff') == 'False':
        print('    * Tagged with AutoOff=False.  Will not delete.')
        return True

    if getTagValue(stack_tags, 'elasticbeanstalk:environment-id'):
        print('    * Elastic beanstalk managed stack (Beanstalk environment: ' + getTagValue(stack_tags, 'elasticbeanstalk:environment-id') + '). Will not delete.')
        return True

    if stack['StackName'] in protected_stack_names:
        print('    * Stack named in protected stack list.  Will not delete.')
        return True

    #  If the stack has a parent - we'll assume that the cleanup will be done from the parent level
    try:
        if stack['ParentId']:
            print('    * Child stack (Parent=' + stack['ParentId'] + '.  Will not delete.')
            return True
    except KeyError:
        pass

    try:
        if stack['EnableTerminationProtection']:
            if stack['EnableTerminationProtection'] == 'true':
                print('    * EnableTerminationProtection=true.  Will not delete.')
                return True
    except KeyError:
        pass

    return False


def terminate_cloudformation_stack(stack, cloudformation_client):
    print('    DELETE STACK : StackName=' + stack['StackName'] + ', StackId=' + stack['StackId'])
    try:
        delete_stack_response = cloudformation_client.delete_stack(StackName=stack['StackName'])
    except botocore.exceptions.ClientError as e:
        error = e.response['Error']
        error_code = error['Code']
        message = error['Message']
        print('    *!  Exception while trying to delete stack: ErrorCode=' + error_code + ', Message=' + message)

def handler(event, context):

    #  Is the function running in report only mode (no deletions to be performed?)
    #  Default to running in report only mode
    try:
        perform_delete_actions = os.environ['PERFORM_DELETE_ACTIONS']
        print('Environment variable PERFORM_DELETE_ACTIONS set to ' + perform_delete_actions +
              '. Set to \'True\' to remove resources marked for deletion.')
    except KeyError:
        perform_delete_actions = 'False'
        print('Environment variable PERFORM_DELETE_ACTIONS not set.' +
              ' Set to \'True\' to remove resources marked for deletion.')


    #  Get AWS session
    session = boto3.session.Session()

    stacks_to_delete = []
    beanstalks_to_delete = []
    ec2_instances_to_delete = []

    print('***  CLOUDFORMATION STACKS')

    #  Get cloudformation client
    cloudformation_client = session.client('cloudformation')

    #  List all 'active' cloudformation stacks
    describe_stacks_paginator = cloudformation_client.get_paginator('describe_stacks')
    describe_stacks_page_iterator = describe_stacks_paginator.paginate()

    # Iterate over the stacks returned
    for page in describe_stacks_page_iterator:
        stack_descriptions = page['Stacks']
        for stack in stack_descriptions:

            # If the stack is an 'active' stack & it is not a protected stack, then add it to the list of stacks to be
            # deleted.
            if stack['StackStatus'] in active_stack_statuses:
                print('  - Active stack. Name=' + stack['StackName'] + ', Id =' + stack['StackId'] + ', Status=' + stack['StackStatus'])

                if not is_cloudformation_stack_protected(stack):
                    print('    * Marked for deletion.')
                    stacks_to_delete.append(stack)

        if len(stacks_to_delete) > 0:
            print('# Stacks marked for deletion: ' + str(len(stacks_to_delete)))
        else:
            print('# No stacks marked for deletion.')


    ### CLEAN UP ELASTIC BEANSTALKS
    print()
    print('***  ELASTIC BEANSTALK ENVIRONMENTS')

    #  Get cloudformation client
    beanstalk_client = session.client('elasticbeanstalk')

    # Do describe_environments call
    describe_response = beanstalk_client.describe_environments(IncludeDeleted=False)

    #  Iterate over beanstalk environments returned
    environments = describe_response['Environments']
    if len(environments) > 0:
        for env in environments:
            if env['Status'] not in ('Updating', 'Ready'):
                print('    * Status not Ready or Updating.  Will not delete.')
            else:
                print('  - Beanstalk environment: EnvironmentName=' + env['EnvironmentName'] +
                      ', Status=' + env['Status'])
                tags = beanstalk_client.list_tags_for_resource(ResourceArn=env['EnvironmentArn'])

                if not is_beanstalk_protected(tags['ResourceTags']):
                    print('    * Marked for deletion.')
                    beanstalks_to_delete.append(env)

        print('# Elastic beanstalks marked for deletion: ' + str(len(beanstalks_to_delete)))

    else:
        print('No elastic beanstalk environments found.')


    ###  Clean up EC2 instances
    print()
    print('***  EC2 INSTANCES')

    # define the connection
    ec2_client = session.client('ec2')

    # Use the filter() method of the instances collection to retrieve
    # all running EC2 instances.
    filters = [
        {
            'Name': 'instance-state-name',
            'Values': ['running']
        }
    ]

    # Run describe_instances using pagination
    describe_instances_paginator = ec2_client.get_paginator('describe_instances')
    describe_instances_page_iterator = describe_instances_paginator.paginate(Filters=filters)

    for page in describe_instances_page_iterator:

        # Iterate over the returned information
        reservations = page['Reservations']
        if len(reservations) > 0:
            for reservation in reservations:
                instances = reservation['Instances']
                if len(instances) > 0:
                    for instance in instances:
                        print('  - EC2 Instance: InstanceId=' + instance['InstanceId'])
                        tags = instance['Tags']

                        if not is_ec2_instance_protected(tags):
                            ec2_instances_to_delete.append(instance)
                else:
                    print('No EC2 instances found.')

            print('# EC2 instances marked for deletion: ' + str(len(ec2_instances_to_delete)))
        else:
            print('No EC2 instances found.')


    #  If report_only_mode not set to 'true' - do the shutdown/terminate actions
    if perform_delete_actions == 'True':

        print()
        print('*** PERFORMING DELETE/TERMINATE ACTIONS')
        ###  PERFORM DELETIONS
        if len(stacks_to_delete) > 0:
            for stack in stacks_to_delete:
                terminate_cloudformation_stack(stack, cloudformation_client)
        else:
            print('  No cloudformation stacks to delete.')

        if len(beanstalks_to_delete) > 0:
            for beanstalk in beanstalks_to_delete:
                print('Beanstalk: ' + beanstalk['EnvironmentName'])
                terminate_beanstalk_environment(beanstalk, beanstalk_client)
        else:
            print('  No beanstalk environments to delete.')

        if len(ec2_instances_to_delete) > 0:
            for instance in ec2_instances_to_delete:
                print('Instance: ' + instance['InstanceId'])
                terminate_ec2_instance(instance, ec2_client)
        else:
            print('  No EC2 instances to delete.')


# MAIN
handler(None, None)
