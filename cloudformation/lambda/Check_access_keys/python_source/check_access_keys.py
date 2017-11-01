import logging
import datetime
import boto3
import click

# setup simple logging for INFO
logging.basicConfig()
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# define the connection
client = boto3.client('iam')


@click.command(context_settings=dict(help_option_names=['-h', '--help']))
@click.option('-e', '--excluded_users', type=click.STRING, envvar='excluded_users', multiple=True,
              help='Users whose access keys should not be checked')
@click.option('-t', '--topic', type=click.STRING, envvar='topic', required=True,
              help='The AWS arn of the SNS topic where the notification will be published')
@click.option('-a', '--age_threshold', type=click.INT, envvar='age_threshold', default=90,
              help='Age threshold in days. Any access key older than the age threshold will trigger a notification')
def main(excluded_users, topic, age_threshold):
    execute(excluded_users, topic, age_threshold)


def execute(excluded_users, topic, age_threshold):
    hit = False
    message = 'The following keys need to be rotated due to age:' + '\n'

    for user in client.list_users()['Users']:
        username = user['UserName']
        if username in excluded_users:
            continue

        keys = client.list_access_keys(UserName=username)
        for key in keys['AccessKeyMetadata']:
            status = key['Status']
            key_id = key['AccessKeyId']

            create_date = key['CreateDate'].date()
            age = datetime.date.today() - create_date
            if age > datetime.timedelta(days=age_threshold) and status == "Active":
                hit = True
                message += 'AccessKeyId: ' + key_id + ', '
                message += 'User: ' + username + ', '
                message += 'Age: ' + str(age.days) + ' days' + '\n'

    if hit:
        sns_client = boto3.client('sns')
        sns_client.publish(
            TopicArn=topic,
            Message=message,
            Subject='Access Key Rotation Reminder')


def lambda_handler(event, context):
    age_threshold = int(event['age_threshold'])
    execute(event['excluded_users'], event['topic'], age_threshold)

if __name__ == '__main__':
    main()
