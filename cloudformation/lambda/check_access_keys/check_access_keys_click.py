import click

from check_access_keys import execute


# allows check_access_keys to be run from command line rather than lambda
@click.command(context_settings=dict(help_option_names=['-h', '--help']))
@click.option('-e', '--excluded_users', type=click.STRING, envvar='excluded_users', multiple=True,
              help='Users whose access keys should not be checked')
@click.option('-t', '--topic', type=click.STRING, envvar='topic', required=True,
              help='The AWS arn of the SNS topic where the notification will be published')
@click.option('-a', '--age_threshold', type=click.INT, envvar='age_threshold', default=90,
              help='Age threshold in days. Any access key older than the age threshold will trigger a notification')
def main(excluded_users, topic, age_threshold):
    execute(excluded_users, topic, age_threshold)


if __name__ == '__main__':
    main()
