# This file defines the necessary variables for the resources used in this project.
variable "domain_name" {
  description = "Domain name for the project"
  type        = string
  default     = "ajripa.click"
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

# Specifies the ARN of the AWS admin user for access in the AWS Console.
# By default, this is set to the root user of the account.
variable "aws_admin_arn" {
  description = "ARN of the AWS admin user"
  type        = string
  default     = ""
}

# Define a variable to specify default tags for resources created by Terraform.
# These tags will automatically be applied to all managed resources, ensuring consistency
# and aiding in cost tracking and project organization.
variable "tags" {
  description = "Default tags applied to all resources"
  type        = map(string)
  default = {
    CreatedBy = "Terraform"
    Owner     = "ajripa@uoc.edu"
    Project   = "TFG"
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
  default     = "tfg-eks"
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

# Specifies whether to enable on-demand instances for the managed node groups.
# By default, this is set to false.
variable "eks_enable_on_demand" {
  description = "Enable On-Demand managed node group"
  type        = bool
  default     = false
}

# Specifies whether to enable Spot instances for the managed node groups.
# By default, this is set to true
variable "eks_enable_spot" {
  description = "Enable Spot managed node group"
  type        = bool
  default     = true
}

# Specifies whether to enable Fargate profile for the EKS cluster.
# By default, this is set to true, but it can be disabled if not needed.
# Only namespaces starting with "fargate" will be scheduled on Fargate.
variable "eks_enable_fargate" {
  description = "Enable Fargate profile"
  type        = bool
  default     = true
}

# ArgoCD Admin User from GitHub
variable "argocd_admin_user" {
  description = "ArgoCD admin user"
  type        = string
  default     = "ajripa@uoc.edu"
}

# Specifies the GitHub repo URL
variable "github_repo_url" {
  description = "GitHub URL"
  type        = string
  default     = "https://github.com/ajripa-uoc/tfg-iac.git"
}

# Specifies the GitHub provider configuration for authenticating with GitHub using a GitHub App.
variable "github_app_client_id" {
  description = "GitHub App client ID"
  type        = string
}

# Specifies the GitHub App secret for authenticating with GitHub App
variable "github_app_secret" {
  description = "GitHub App secret"
  type        = string
}

# Specifies the Route 53 Zone ID for the DNS zone in which records will be managed.
# This ID uniquely identifies the hosted zone in AWS Route 53 where domain records
# (such as A, CNAME, and TXT records) will be created and updated by the external-dns controller.
variable "route53_zone_id" {
  description = "Route53 Zone ID"
  type        = string
  default     = "Z05771062CFVMZEORD9FE"
}

# Initial empty values for ArgoCD secret
variable "argocd_secret" {
  default = {
    token    = ""
    hostname        = ""
    admin_password  = ""
  }
  type = map(string)
}

# EFS Name
# EFS is used by EKS for persistent storage
variable "efs_name" {
  description = "Name of the EFS"
  type        = string
  default     = "tfg-efs"
}