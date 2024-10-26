# Fetches a list of available availability zones in the current region
data "aws_availability_zones" "available" {}

# Defines local variable `azs` to use the first 3 availability zones for subnet distribution
locals {
    azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

#VPC module configuration for creating a virtual private cloud
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 52)]

  enable_nat_gateway = true     # Enables a NAT gateway for internet access in private subnets
  single_nat_gateway = true     # Deploys a single NAT gateway to reduce costs

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1 # Tag to identify public subnets for external load balancers used by k8s
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1 # Tag to identify private subnets for internal load balancers used by k8s
  }

}