# AWS EFS (Elastic File System)
# Used by the EKS cluster for persistent storage.

# Define a static map from the dynamically generated list of private subnets.
# This ensures that the keys (e.g., "subnet-1", "subnet-2") are statically defined,
# allowing Terraform to evaluate the for_each argument at plan time.
locals {
  private_subnets_map = {
    "subnet-1" = module.vpc.private_subnets[0]
    "subnet-2" = module.vpc.private_subnets[1]
    "subnet-3" = module.vpc.private_subnets[2]
  }
}

# Security Group
# Defines network access rules for the EFS, allowing traffic only from the EKS cluster.
resource "aws_security_group" "efs" {
  name        = "${var.efs_name}-sg"
  description = "Allow NFS traffic from EKS cluster"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "nfs"
    from_port        = 2049
    to_port          = 2049
    protocol         = "TCP"
    security_groups = [module.eks.cluster_primary_security_group_id]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.efs_name}-sg"
    }
  )
}

# Elastic File System
# Creates the EFS resource to be used by the EKS cluster.
resource "aws_efs_file_system" "efs" {
  creation_token = "eks-efs"

  tags = merge(
    var.tags,
    {
        Name = var.efs_name
    }
  )
}

# EFS Mount Targets
# Configures EFS mount points in each private subnet of the VPC.∫
resource "aws_efs_mount_target" "mount" {
  for_each = local.private_subnets_map

  subnet_id = each.value
  file_system_id = aws_efs_file_system.efs.id
  security_groups = [aws_security_group.efs.id]
}

# Create a Kubernetes storage class for EFS
resource "kubernetes_storage_class" "efs" {
  depends_on = [ module.eks ]
  metadata {
    name = "efs"
  }

  storage_provisioner = "efs.csi.aws.com"
  reclaim_policy      = "Retain"
  allow_volume_expansion = true
  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId = aws_efs_file_system.efs.id
    directoryPerms = "777"
    gid = "1000"
    uid = "1000"
  }
}