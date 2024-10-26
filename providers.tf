# This file configures the required providers for this Terraform project.
# It specifies the minimum Terraform version needed and the external providers
# (e.g., AWS) with their respective source and version constraints.

# Define Terraform and required providers
terraform {
    required_version = ">=1.9.0"
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 3.0"
        }
    }
}

# AWS Provider configuration module
# This module sets up the AWS provider with the necessary configuration parameters,
# such as the AWS region to use, which is provided via a variable.
module "aws_provider" {
  source     = "../../core/providers/aws"
  aws_region = var.aws_region
}