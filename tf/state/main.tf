# Define an S3 bucket for remote and shared Terraform state storage, together
# with a DynamoDB table for state locking.

provider "aws" {
  region = "eu-central-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_s3_bucket" "tf_state" {
  bucket = "terraform.tfstate.xyz"
  #lifecycle {
  #  prevent_destroy = true
  #}
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "tf_lock" {
  name           = "terraform.lock"
  hash_key       = "LockID"
  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    ignore_changes = [read_capacity, write_capacity]
  }

  server_side_encryption {
    enabled = true
  }
}

output "tf_state_bucket" {
  value = aws_s3_bucket.tf_state.id
}

output "tf_state_lock" {
  value = aws_dynamodb_table.tf_lock.id
}
