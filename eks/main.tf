# EKS module configuration for creating a new EKS cluster
# https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_cluster_version

  # EKS Addons for essential networking and DNS functionality
  cluster_addons = {
    coredns                = {} # CoreDNS for DNS management within the cluster
    eks-pod-identity-agent = {} # Pod Identity Agent for IAM role management
    kube-proxy             = {} # Kube-Proxy for networking
    vpc-cni                = {} # VPC CNI for VPC-native networking
  }

  ## VPC configuration from VPC module
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Define managed node groups for the EKS cluster based on variables
  eks_managed_node_groups = merge(
    var.eks_enable_on_demand ? {
        on-demand = {
        instance_types = var.eks_instance_type
        min_size = 2
        max_size = 5
        desired_size = 2
        }
    } : {},

    var.eks_enable_spot ? {
        spot = {
        instance_types = var.eks_instance_type
        min_size = 2
        max_size = 5
        desired_size = 2
        capacity_type = "SPOT" # Capacity type set to Spot for cost savings
        }
  } : {}
  )

  # Fargate profiles
  fargate_profiles = var.eks_enable_fargate ? {
    kube-system-profile = {
      name = "kube-system"
      selectors = [
        {
          namespace = "kube-system"
        },
        {
          namespace = "default"
        }
      ]
      subnets = module.vpc.private_subnets
    }
  } : {}


  # Defines access entries for assigning IAM roles and policies to Kubernetes groups.
  # This allows access to the EKS cluster and its resources in AWS Console.
  access_entries = {
    my_entry = {
      kubernetes_groups = []
      principal_arn     = var.aws_admin_arn

      policy_associations = {
        cluster = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  tags = var.tags # Tags to apply to all resources
}