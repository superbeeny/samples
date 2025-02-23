extension aws
extension radius

param environment string
param queue_name string

@secure()
param aws_access_key_id string
@secure()
param aws_secret_access_key string
param aws_region string

param image string = 'ghcr.io/radius-project/samples/aws-sqs-sample:latest'

var aws_credential = {
  AWS_ACCESS_KEY_ID: aws_access_key_id
  AWS_SECRET_ACCESS_KEY: aws_secret_access_key
  AWS_REGION: aws_region
}

var app_name = 'sqs-sample-app'
resource app 'Applications.Core/applications@2023-10-01-preview' = {
  name: app_name
  properties: {
    environment: environment
  }
}

resource queue 'AWS.SQS/Queue@default' = {
  alias: 'sqs-sample-app-${queue_name}'
  name: 'sqs-sample-app-${queue_name}'
  properties: {
    QueueName: 'sqs-sample-app-${queue_name}'
  }
}

resource producer 'Applications.Core/containers@2023-10-01-preview' = {
  name: 'producer'
  properties: {
    application: app.id
    container: {
      env: union(
        {
          SQS_QUEUE_URL: queue.properties.QueueUrl
          HTTP_SERVER_PORT: '3000'
        },
        aws_credential
      )
      image: image
    }
  }
}

resource consumer 'Applications.Core/containers@2023-10-01-preview' = {
  name: 'consumer'
  properties: {
    application: app.id
    container: {
      env: union(
        {
          SQS_QUEUE_URL: queue.properties.QueueUrl
          HTTP_SERVER_PORT: '4000'
        },
        aws_credential
      )
      image: image
    }
  }
}
