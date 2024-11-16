# Deploy ArgoCD using Helm, a package manager for Kubernetes applications.
# ArgoCD is a declarative GitOps tool for continuous deployment of applications to Kubernetes.
# The Helm chart used here can be found on Artifact Hub, which provides pre-configured options
# for installing and managing ArgoCD.
# Reference: https://artifacthub.io/packages/helm/argo/argo-cd


# Deploy the ArgoCD Helm chart with the specified values
resource "helm_release" "argocd" {
  depends_on       = [helm_release.aws_alb_controller]
  name             = "argocd"
  chart            = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  version          = "7.6.12"
  timeout          = "1500"
  create_namespace = true
  namespace        = "argocd"

  values = [templatefile("templates/argocd.yaml.tpl", {
    argocd_admin_user        = var.argocd_admin_user,
    github_app_client_id     = var.github_app_client_id,
    github_app_client_secret = var.github_app_secret,
    domain_name              = "argocd.${var.domain_name}"
  })]
}

# Generate ArgoCD token after installation
# This token will be stored in AWS Secrets Manager and will be used by the GitOps pipeline
resource "null_resource" "argocd_token" {
  depends_on = [
    helm_release.argocd,
    aws_secretsmanager_secret_version.argocd_token,
    aws_secretsmanager_secret_version.argocd_hostname
    ]

  provisioner "local-exec" {
    command = <<-EOT
      # Wait for ArgoCD server to be ready
      kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

      # Get the initial admin password
      ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

      # Get ArgoCD hostname
      ARGOCD_HOSTNAME=$(kubectl get ingress argocd-server -n argocd -o jsonpath='{.spec.rules[0].host}')

      # Login to ArgoCD
      argocd login $ARGOCD_HOSTNAME \
        --username admin \
        --password $ARGOCD_PASSWORD \
        --insecure

      # Generate token for Gitops user
      TOKEN=$(argocd account generate-token --account gitops --grpc-web)

      # Update the AWS Secret
      aws secretsmanager update-secret \
        --secret-id ${aws_secretsmanager_secret.argocd_token.id} \
        --secret-string "$TOKEN" \
        --region ${var.aws_region}

      # Update hostname in AWS Secret
      aws secretsmanager update-secret \
        --secret-id ${aws_secretsmanager_secret.argocd_hostname.id} \
        --secret-string "$ARGOCD_HOSTNAME" \
        --region ${var.aws_region}
    EOT
  }
}

# Create AWS Secret for the token
resource "aws_secretsmanager_secret" "argocd_token" {
  name = "argocd/gitops-token"
}

# Store the token in AWS Secrets Manager
resource "aws_secretsmanager_secret_version" "argocd_token" {
  secret_id     = aws_secretsmanager_secret.argocd_token.id
  secret_string = <<EOT
    {
      "": ""
    }
    EOT
}

# Create AWS Secret for the hostname
resource "aws_secretsmanager_secret" "argocd_hostname" {
  name = "argocd/hostname"
}

# Store the token in AWS Secrets Manager
resource "aws_secretsmanager_secret_version" "argocd_hostname" {
  secret_id     = aws_secretsmanager_secret.argocd_hostname.id
  secret_string = <<EOT
    {
      "": ""
    }
    EOT
}