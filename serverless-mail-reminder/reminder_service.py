import boto3

sns = boto3.client('sns')

def handler(event,context):
    sns.publish(
        TopicArn='',
        Message=(
            'Hello! This is your reminder to '
            'schedule an AWS Certification Exam!'
        )
    )
    return 'success'
