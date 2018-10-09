# Serverless Text Message Reminder
## Environment
![alt text](../Images/serverless-text-message-reminder.png "Serverless Mail Reminder Image")

## Technologies

1. Lambda Functions
    * [Lambda Documentation](https://docs.aws.amazon.com/lambda/index.html?id=docs_gateway#lang/en_us)
1. SNS Topics
    * [SNS Documentation](https://docs.aws.amazon.com/sns/index.html?id=docs_gateway#lang/en_us)
1. Python
    * [Python Documentation](https://www.python.org/doc/)

## Configuration Steps

1. Create a Lambda Role

    1. IAM
    1. Roles
    1. Click `Create role`
    1. Click `Lambda`
    1. Click `Next: Permissions`
    1. Click `Create policy`
    1. Click `JSON`
    1. Paste the provided JSON code in the codeblock, you can find this code in lambdaCode.json
    1. Click `Review Policy`
    1. Give the policy a name e.g. `lambdaFunctionPolicy`
    1. Go back to `Create role` and now we can use the policy in the Role
    1. Give the role a name e.g. `lambdaFunctionRole`

1. Create a Lambda Function

    1. Services
    1. Lambda
    1. Click `Create function`
    1. Click `Author from scratch`
    1. Give the function a name for example `lambdaExample`
    1. Choose the correct runtime environment, we are using Python3.6
    1. Choose `Choose an existing role` in the `Role` dropdown menu
    1. Choose the role you created in the first step `lambdaFunctionRole`
    1. Click `Create function`
    1. Paste the `reminder_service.py` code provided in this repo in the `lambda_function.py` codeblock
    1. Edit the `Handler` to `lambda_fuction.handler`
    1. At the moment the string is empty for `TopicArn`, to fill in this parameter we first have to create an `SNS Topic` do this in a new tab!

1. Create SNS Topic

    1. Services
    1. Simple Notification Service
    1. Click `Get Started`
    1. Click `Create topic`
    1. Name the topic e.g. `EmailTopic` and use the same display name
    1. Now paste the `Topic ARN` in the parameter for the Lambda function
    1. Click `Create subscription`
    1. Choose `Email` as protocol
    1. Use your own email address as `EndPoint`
    1. An email will be send to your email address which you have to confirm

1. Save the lambda function

1. In the designer list choose `CloudWatch Events`

    1. Choose create a new rule
    1. Give the rule a name
    1. Use a scheduled rule
    1. Use a rate e.g. rate(1 minute)
    1. Save the rule


## Recap

We now created a Lambda function that will notify an SNS topic when a pre defined event happens. With this basic setup you could do more than only spam yourself every minute with a `Hello` mail. One of the possible setups would be that you get notified when someone uploads a file in a specific `S3 Bucket`.
