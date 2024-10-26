# This file defines the necessary variables for the resources used in this project.
# These variables configure the S3 bucket and DynamoDB table for Terraform state management,
# as well as the AWS region where the resources will be deployed and the profile to use for authentication.


# Name of the S3 bucket used to store the Terraform state file.
variable "s3_bucket_name" {
  description = "S3 Bucket Name"
  type = string
}

# Name of the DynamoDB table used for state locking.
variable "dynamodb_table_name" {
  description = "DynamoDB Table Name"
  type = string
}

# AWS region where the infrastructure resources (e.g., S3 bucket, DynamoDB table) will be created.
# By default, this is set to the EU (Ireland) region, but it can be customized.
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "eu-west-1"
}

# AWS CLI profile to be used for authentication.
# If left empty, the default AWS profile will be used.
# This allows flexibility for users who may have multiple AWS profiles configured.
variable "aws_profile" {
  description = "AWS Profile"
  type        = string
  default     = ""
}

# Define a variable to specify default tags for resources created by Terraform.
# These tags will automatically be applied to all managed resources, ensuring consistency
# and aiding in cost tracking and project organization.
variable "tags" {
  description = "Default tags applied to all resources"
  type = map(string)
  default = {
    CreatedBy = "Terraform"
    Owner      = "ajripa@uoc.edu"
    Project    = "TFG"
  }
}