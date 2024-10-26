# This file is responsible for creating the necessary resources for the Terraform state
# It uses the modules provided by AWS for S3 and DynamoDB
# https://registry.terraform.io/modules/terraform-aws-modules

# S3 bucket to store the Terraform state
# https://registry.terraform.io/modules/terraform-aws-modules/s3/aws/latest

module "s3" {
  source = "./modules/aws/s3"
  s3_bucket_name = var.s3_bucket_name
}

# DynamoDB table for Terraform state locking
# https://registry.terraform.io/modules/terraform-aws-modules/dynamodb/aws/latest

module "dynamodb" {
  source = "./modules/aws/dynamodb"
  dynamodb_table_name = var.dynamodb_table_name
}
