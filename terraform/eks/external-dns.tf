# Install the external-dns controller in the EKS cluster.
# The external-dns controller automates the management of DNS records, ensuring that the domain names
# for services deployed in the Kubernetes cluster are dynamically updated in the configured DNS provider
# (such as Route 53). This is especially useful for automating domain assignments
# to services with changing IPs or load balancers in a cloud-native environment.
# Ref: https://artifacthub.io/packages/helm/bitnami/external-dns

# Role-based access control (RBAC) configuration for the external-dns controller.
# This IAM role allows the external-dns controller to assume the role and manage Route 53 DNS records.
module "external_dns_role" {
  depends_on = [module.eks]
  source     = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                  = "eks-external-dns-role"
  attach_external_dns_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:external-dns"]
    }
  }

  tags = var.tags
}

# Install External DNS chart
resource "helm_release" "external_dns" {
  depends_on = [module.external_dns_role]
  name       = "external-dns"
  chart      = "external-dns"
  repository = "oci://registry-1.docker.io/bitnamicharts/"
  version    = "8.3.12"
  timeout    = "1500"
  namespace  = "kube-system"
  values = [templatefile("templates/external-dns.yaml.tpl", {
    provider      = "aws",
    aws_zone_type = "public",
    domain_name   = var.domain_name,
    txt_owner_id  = module.eks.cluster_name
    iam_role_arn  = module.external_dns_role.iam_role_arn
  })]
}

# Create a null resource ensure that external-dns cleans up DNS records when destroyed
resource "time_sleep" "dns_cleanup" {
  depends_on = [helm_release.external_dns]

  destroy_duration = "60s"
}