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

# Specifies the name assigned to the EKS cluster for identification and management.
variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "tfg-eks-cluster"
}

# Defines the Kubernetes version for the EKS cluster.
variable "eks_cluster_version" {
  description = "Version of the EKS cluster"
  type        = string
  default     = "1.31"
}

# Specifies the list of instance types used for the EKS managed node groups.
variable "eks_instance_type" {
  description = "Instance type for the EKS manged nodes"
  type        = list(string)
  default     = ["m6i.large", "t3.large", "t3a.large"]
}

# Specifies the ARN of the AWS admin user for access to the EKS cluster in the AWS Console.
variable "aws_admin_arn" {
  description = "ARN of the AWS admin user"
  type        = string
  default     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
}


