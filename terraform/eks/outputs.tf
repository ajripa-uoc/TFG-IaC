# ArgoCD URL
output "argocd_url" {
  description = "ArgoCD URL"
  value       = "https://argocd.${var.domain_name}"
}

# ArgoCD credentials
data "aws_secretsmanager_secret_version" "argocd_current" {
  depends_on = [null_resource.argocd_token]
  secret_id  = aws_secretsmanager_secret.argocd.id
}

# Not sensitive output for ArgoCD credentials.
# This is not secure, but it is only used for debugging purposes.
output "argocd_admin_password" {
  description = "ArgoCD admin password"
  value       = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.argocd_current.secret_string)["admin_password"])
  sensitive   = true
}

output "argocd_token" {
  description = "ArgoCD token"
  value       = nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.argocd_current.secret_string)["token"])
  sensitive   = true
}
