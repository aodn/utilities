import logging
import boto3

# setup simple logging for INFO
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# define the connection
client = boto3.client('elasticbeanstalk')
skip_envs = ["geoserver-systest", "geowebcache-systest", 'aodn-portal-sandbox', 'geoserver-sandbox',
             'geowebcache-sandbox', 'thredds-sandbox']


def handler(event, context):
    response_de = client.describe_environments(IncludeDeleted=False)
    logger.debug('Beanstalk Environments: ' + str(response_de))

    for env in response_de['Environments']:

        if not env['EnvironmentName'].endswith('-prod') \
                and env['EnvironmentName'] not in skip_envs \
                and env['Status'] in ('Updating', 'Ready'):

            logger.info("TERMINATING {0} ({1})".format(env['EnvironmentName'], env['Status']))
            ###############
            terminate(env)
            ###############
        else:
            logger.info("EXCLUDING {0} ({1})".format(env['EnvironmentName'], env['Status']))


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


