# Install the external-dns controller in the EKS cluster.
# The external-dns controller automates the management of DNS records, ensuring that the domain names
# for services deployed in the Kubernetes cluster are dynamically updated in the configured DNS provider
# (such as Route 53). This is especially useful for automating domain assignments
# to services with changing IPs or load balancers in a cloud-native environment.
# Ref: https://artifacthub.io/packages/helm/bitnami/external-dns

resource "helm_release" "external_dns" {
  depends_on = [module.eks]
  name       = "external-dns"
  chart      = "external-dns"
  repository = "oci://registry-1.docker.io/bitnamicharts/"
  version    = "8.3.12"
  timeout    = "1500"
  create_namespace = true
  namespace  = "external-dns"
  values  = [templatefile("templates/external-dns.yaml.tpl", {
    provider        = "aws",
    aws_zone_type   = "public",
    txt_owner_id    = var.route53_zone_id
  })]
}

# Role-based access control (RBAC) configuration for the external-dns controller.
# This IAM role allows the external-dns controller to assume the role and manage Route 53 DNS records.
module "iam_assumable_role_with_oidc" {
  source            = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  create_role       = true
  role_name         = "external-dns-role-with-oidc"
  provider_url      = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns  = [aws_iam_policy.external_dns.arn]
  number_of_role_policy_arns = 1

  tags = var.tags
}

# IAM policy for the external-dns controller.
resource "aws_iam_policy" "external_dns" {
  name_prefix = "external-dns-policy"
  description = "Policy for external-dns controller"
  policy      = file("policies/external_dns_iam_policy.json")
}