# Configure Providers
terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 5.0.0"
      }
    }
    backend "local" {
      path = "./terraform.tfstate"
    }
}
# Configure Regions
provider "aws" {
    region = "us-west-2"
}
# Create S3 Bucket
resource "aws_s3_bucket" "s3-workshop" {
    bucket = "potix-workshop-bucket"
    # force_destroy = true
    tags = {
        Name = "potix-workshop-bucket"
    }
}
# Allow Pubic Access with Bucket Policy
# resource "aws_s3_bucket_public_access_block" "allow_public" {
#   bucket = aws_s3_bucket.s3-workshop.id

#   block_public_acls       = false
#   block_public_policy     = false
#   ignore_public_acls      = false
#   restrict_public_buckets = false
# }
# # Allow Accessing /public with Bucket Policy
# resource "aws_s3_bucket_policy" "allow_public_get" {
#   bucket = aws_s3_bucket.s3-workshop.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid       = "PublicReadGetObject"
#         Effect    = "Allow"
#         Principal = "*"
#         Action    = "s3:GetObject"
#         Resource  = "${aws_s3_bucket.s3-workshop.arn}/public"
#       },
#     ]
#   })

#   depends_on = [aws_s3_bucket_public_access_block.allow_public]
# }
