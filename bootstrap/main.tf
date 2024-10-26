# This file is responsible for creating the necessary resources for the Terraform state
# It uses the modules provided by AWS for S3 and DynamoDB
# https://registry.terraform.io/modules/terraform-aws-modules

# S3 bucket to store the Terraform state
# https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest

module "s3" {
  source = "terraform-aws-modules/s3-bucket/aws"
  bucket = var.s3_bucket_name

  versioning = {
    enabled = true
  }
}

# DynamoDB table for Terraform state locking
# https://registry.terraform.io/modules/terraform-aws-modules/dynamodb-table/aws/latest

module "dynamodb" {
  source   = "terraform-aws-modules/dynamodb-table/aws"
  name = var.dynamodb_table_name
  hash_key = "LockID"

  attributes = [
    {
      name = "LockID"
      type = "S"
    }
  ]
}
