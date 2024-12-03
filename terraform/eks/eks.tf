# EKS module configuration for creating a new EKS cluster
# https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest

module "eks" {
  depends_on = [module.vpc]
  source     = "terraform-aws-modules/eks/aws"
  version    = "~> 20.0"

  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_cluster_version

  create_cluster_security_group            = false # Disable the creation of a security group for the EKS cluster to avoid conflicts with fargate
  create_node_security_group               = false # Disable the creation of a security group for the EKS nodes to avoid conflicts with fargate
  cluster_endpoint_public_access           = true  # Enable public access to the EKS cluster endpoint
  enable_cluster_creator_admin_permissions = true  # Enable IAM permissions for the cluster creator

  # EKS Addons for essential networking and DNS functionality
  cluster_addons = {
    coredns                = { most_recent = true } # CoreDNS for DNS management within the cluster
    eks-pod-identity-agent = { most_recent = true } # Pod Identity Agent for IAM role management
    kube-proxy             = { most_recent = true } # Kube-Proxy for networking
    vpc-cni                = { most_recent = true } # VPC CNI for VPC-native networking
    aws-ebs-csi-driver     = { most_recent = true } # EBS CSI Driver for EBS volume management
    aws-efs-csi-driver     = { most_recent = true } # EFS CSI Driver for EFS volume management
  }

  ## VPC configuration from VPC module
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Define managed node groups for the EKS cluster based on variables
  eks_managed_node_group_defaults = {
    instance_types = var.eks_instance_type
    # IAM instance profile for the managed node group for volume management
    iam_role_additional_policies = {
      AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      AmazonEFSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
      }
  }

  eks_managed_node_groups = merge(
    var.eks_enable_on_demand ? {
      on-demand = {
        min_size     = 2
        max_size     = 5
        desired_size = 2
      }
    } : {},

    var.eks_enable_spot ? {
      spot = {
        min_size      = 2
        max_size      = 5
        desired_size  = 2
        capacity_type = "SPOT" # Capacity type set to Spot for cost savings
      }
    } : {}
  )

  # Fargate profiles
  fargate_profiles = var.eks_enable_fargate ? {
    default-profile = {
      name = "fargate-profile"
      selectors = [
        {
          namespace = "fargate*" # Pods in namespaces starting with "fargate" will be scheduled on Fargate
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

# Update the kubeconfig file with the new EKS cluster
# After your EKS cluster resource, add:
resource "null_resource" "update_kubeconfig" {
  depends_on = [module.eks.cluster_id]  # Or your cluster resource name

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}"
  }
}