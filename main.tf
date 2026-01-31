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