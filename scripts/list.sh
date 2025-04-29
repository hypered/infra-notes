#! /usr/bin/env bash

echo "EC2 instances:"
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,PublicIpAddress,PrivateIpAddress]' --output table --region eu-central-1

echo "S3 buckets:"
aws s3 ls

echo "S3 bucket state:"
aws s3 ls s3://terraform.tfstate.xyz

echo "S3 bucket import:"
aws s3 ls s3://common-import-bucket

echo "DynamoDB tables:"
aws dynamodb list-tables --region eu-central-1
