# Resize images on the fly
## Environment
![alt text](../Images/on-the-fly-image-resizer.png "Drupal high available")

1. A user requests a resized asset from an S3 bucket through its static website hosting endpoint. The bucket has a routing rule configured to redirect to the resize API any request for an object that cannot be found.
1. Because the resized asset does not exist in the bucket, the request is temporarily redirected to the resize API method.
1. The user’s browser follows the redirect and requests the resize operation via API Gateway.
1. The API Gateway method is configured to trigger a Lambda function to serve the request.
1. The Lambda function downloads the original image from the S3 bucket, resizes it, and uploads the resized image back into the bucket as the originally requested key.
1. When the Lambda function completes, API Gateway permanently redirects the user to the file stored in S3.
1. The user’s browser requests the now-available resized image from the S3 bucket. Subsequent requests from this and other users will be served directly from S3 and bypass the resize operation. If the resized image is deleted in the future, the above process repeats and the resized image is re-created and replaced into the S3 bucket.

## Technologies

1. S3 Bucket
    * [S3 Documentation](https://docs.aws.amazon.com/s3/index.html?id=docs_gateway#lang/en_us)
1. Lambda
    * [Lamba Documentation](https://docs.aws.amazon.com/lambda/index.html?id=docs_gateway#lang/en_us)

## Configuration Steps

### S3 Bucket

1. Services
1. S3 Bucket
1. Click `Create bucket`
1. Give the bucket a name, this name has to be unique
1. Click `Next`
1. Click `Next`
1. Click `Next`
1. Click `Create bucket`
1. Go to your bucket by clicking on it
1. Click `Permissions`
1. Click `Bucket policy`
1. Paste the allow anonymous access code in the policy editor, replace `examplebucket` with the name of your personal bucket

        {
          "Version":"2012-10-17",
          "Statement":[
            {
              "Sid":"AddPerm",
              "Effect":"Allow",
              "Principal": "*",
              "Action":["s3:GetObject"],
              "Resource":["arn:aws:s3:::examplebucket/*"]
            }
          ]
        }

1. Click `Properties`
1. Enable `Static Website Hosting`
1. For index document use `index.html`
1. Now you've created an endpoint for the bucket

### Lambda Function

1. Services
1. Lambda
1. Click `Create a function`
1. Use the `Author from scratch` Lambda
1. Name the Lamba function `resize`
1. Create a custom role with the following code, paste this in the `Policy Document`

        {
          "Version": "2012-10-17",
          "Statement": [
            {
              "Effect": "Allow",
              "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
              ],
              "Resource": "arn:aws:logs:*:*:*"
            },
            {
              "Effect": "Allow",
              "Action": "s3:PutObject",
              "Resource": "arn:aws:s3:::__YOUR_BUCKET_NAME_HERE__/*"    
            }
          ]
        }

1. Use this role in the Lambda function
1. Click `Next`
1. At the `Function code` option we are going to upload a `.zip` file
1. Now we are going to create 2 `Environment variables`
  1. The first key is `BUCKET` with the value `Bucketname`
  1. The second key is `URL` with the endpoint of your bucket. You can find this endpoint in the static website hosting property of your bucket
1. Choose `1536` on the memory slider
1. Put the timeout seconds on `10`
1. Click `Save`
1. Now we are going to create the trigger
1. On the leftside of the screen you can find `Add triggers`
1. Click on `API Gateway`
1. Create a new `API` and copy the hostname e.g. `erouu2bb79.execute-api.us-east-1.amazonaws.com`
1. We need to use this information in the following codeblock

        <RoutingRules>
          <RoutingRule>
            <Condition>
              <KeyPrefixEquals/>
              <HttpErrorCodeReturnedEquals>404</HttpErrorCodeReturnedEquals>
            </Condition>
            <Redirect>
              <Protocol>https</Protocol>
              <HostName>__YOUR_API_HOSTNAME__</HostName>
              <ReplaceKeyPrefixWith>__YOUR_STAGE__/resize?key=</ReplaceKeyPrefixWith>
              <HttpRedirectCode>307</HttpRedirectCode>
            </Redirect>
          </RoutingRule>
        </RoutingRules>

1. Go back to your bucket and go to `Properties`
1. Go to `Static website hosting`
1. Paste the correct code in  `Redirection rules`
1. Upload an image to your bucket, for example the `blue_marble.jpg` that you can find in this repo


## Result

The result of this lab is that we can now get resized images on demand. You can browse to the following URL to get a `300x300` verion of the image, a `25x25`, ...

`http://YOUR_BUCKET_WEBSITE_HOSTNAME_HERE/300x300/blue_marble.jpg`

`http://YOUR_BUCKET_WEBSITE_HOSTNAME_HERE/25x25/blue_marble.jpg`

`http://YOUR_BUCKET_WEBSITE_HOSTNAME_HERE/500x500/blue_marble.jpg`   

## Recap

In this lab we learned to make an `on-the-fly-image-resizer` with using an `S3 bucket` and the `Lambda functions` from `AWS`.
