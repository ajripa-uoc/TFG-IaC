# This file defines the necessary variables for the resources used in this project.

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

# CIDR block to define the IP range for the VPC. This range determines the IP addresses available
# for subnets and resources within the VPC.
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Name assigned to the VPC for easy identification and management within the AWS environment.
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "tfg-vpc"
}



