# Hands-on Day1
* This folder contains workshop codes for 4 different sections

## IAM
* s3-user-policy.json: Example policy for S3 IAM user

## S3
* terraform: Folder that contains necessary IaC related code
* s3-bucket-policy.json: bucket policy for S3 Bucket public access
* index.html: Just a "hello, world" sample file for S3 static web hosting

## VPC
* terraform: IaC on createing a new VPC
* install-nginx.sh: Sample userdata for Ubuntu 22.04

## EC2
* terraform: IaC on creating two new instances and importing SSH Key
* userdata.sh: Example for userdata (Install nginx and aws-cli)