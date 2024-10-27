# This file configures the required providers for this Terraform project.
# It specifies the minimum Terraform version needed and the external providers
# (e.g., AWS) with their respective source and version constraints.

# Define Terraform and required providers
terraform {
  required_version = ">=1.9.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.9"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.2"
    }
  }
}

# AWS Provider configuration module
# Sets up the AWS provider with the necessary configuration parameters,
# such as the AWS region to use, which is provided via a variable.
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = var.tags
  }
}

# Kubernetes Provider configuration
# Sets up the Kubernetes provider to connect to the EKS cluster using the endpoint
# and certificate authority data provided by the EKS module
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--profile", var.aws_profile]
  }
}

# Kubectl provider configuration
# Configures kubectl access using the EKS endpoint and token
provider "kubectl" {
  apply_retry_count      = 5
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", "us-east-1", "--profile", var.aws_profile]
  }
}

# Helm provider configuration
# Sets up Helm provider to deploy charts in the EKS cluster
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--profile", var.aws_profile]
    }
  }
}