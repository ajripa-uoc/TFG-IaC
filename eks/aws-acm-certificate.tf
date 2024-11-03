# Request a wildcard ACM certificate for the specified domain.
# This certificate will support any subdomain under the specified `domain_name`.
# Ref: https://registry.terraform.io/modules/terraform-aws-modules/acm/aws/latest

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name  = var.domain_name
  zone_id      = var.route53_zone_id

  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.domain_name}",
  ]

  wait_for_validation = true

  tags = var.tags
}
