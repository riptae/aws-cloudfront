# [0] providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

# [1] S3 bucket
resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = "my-bucket-${random_id.suffix.hex}"
}

resource "aws_s3_bucket_public_access_block" "acls" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# [2] s3 object (web page)
resource "aws_s3_object" "site" {
  bucket       = aws_s3_bucket.s3_bucket.id
  key          = "index.html"
  content_type = "text/html; charset=utf-8"

  content = <<EOF
    <!doctype html>
    <html>
        <head>
            <meta charset="utf-8">
            <title>S3+cloudfront</title>
        </head>
        <body>
            <h1>hello CLOUDFRONT + S3(private)</h1>
        </body>
    </html>
  EOF
}

# [3] OAC
resource "aws_cloudfront_origin_access_control" "oac" {
    name = "oac-for-s3"
    description = "OAC for private S3"
    origin_access_control_origin_type = "s3"
    signing_behavior = "always"
    signing_protocol = "sigv4"
}