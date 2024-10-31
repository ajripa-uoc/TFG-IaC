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
  version    = "7.6.12"
  timeout    = "1500"
  create_namespace = true
  namespace  = "external-dns"
  values  = [templatefile("templates/external-dns.yaml.tpl", {
    provider        = "aws",
    aws_zone_type   = "public",
    txt_owner_id    = var.route53_zone_id
  })]
}