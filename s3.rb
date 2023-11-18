require "aws-sdk-s3"

Aws.config.update(
  region: ENV.fetch("S3_UPLOADS_AWS_REGION"),
  credentials: Aws::Credentials.new(
      ENV.fetch("S3_UPLOADS_AWS_ACCESS_KEY_ID"),
      ENV.fetch("S3_UPLOADS_AWS_SECRET_ACCESS_KEY")
    )
)
