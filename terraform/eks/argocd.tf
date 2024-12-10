# Deploy ArgoCD using Helm, a package manager for Kubernetes applications.
# ArgoCD is a declarative GitOps tool for continuous deployment of applications to Kubernetes.
# The Helm chart used here can be found on Artifact Hub, which provides pre-configured options
# for installing and managing ArgoCD.
# Reference: https://artifacthub.io/packages/helm/argo/argo-cd


# Deploy the ArgoCD Helm chart with the specified values
resource "helm_release" "argocd" {
  depends_on       = [helm_release.aws_alb_controller,kubernetes_storage_class.efs]
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
    aws_secretsmanager_secret_version.argocd
    ]

  provisioner "local-exec" {
    command = <<-EOT
      # Wait for ArgoCD server to be ready
      kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

      # Get the initial admin password
      ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

      # Get ArgoCD hostname
      ARGOCD_HOSTNAME=$(kubectl get ingress argocd-server -n argocd -o jsonpath='{.spec.rules[0].host}')

      # Wait until ArgoCD hostname resolves
      MAX_RETRIES=30 # Maximum number of attempts
      RETRY_COUNT=0  # Initialize retry counter
      RETRY_INTERVAL=10 # Seconds between retries

      # Loop until the domain resolves or the maximum retries are reached
      while ! dig +short "$ARGOCD_HOSTNAME" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' > /dev/null; do
        if [ "$RETRY_COUNT" -ge "$MAX_RETRIES" ]; then
          echo "Maximum retries reached. Domain $ARGOCD_HOSTNAME did not resolve."
          exit 1
        fi
        echo "Domain $ARGOCD_HOSTNAME is not yet resolving. Retrying in $RETRY_INTERVAL seconds... (Attempt $((RETRY_COUNT + 1))/$MAX_RETRIES)"
        RETRY_COUNT=$((RETRY_COUNT + 1))
        sleep "$RETRY_INTERVAL"
      done

      # Login to ArgoCD
      argocd login $ARGOCD_HOSTNAME \
        --username admin \
        --password $ARGOCD_PASSWORD \
        --grpc-web

      # Generate token for Gitops user
      TOKEN=$(argocd account generate-token --account gitops --grpc-web)

      # Update token in AWS Secret
      aws secretsmanager update-secret \
      --secret-id ${aws_secretsmanager_secret.argocd.id} \
      --secret-string "$(jq -n \
                    --arg token "$TOKEN" \
                    --arg hostname "$ARGOCD_HOSTNAME" \
                    --arg admin_password "$ARGOCD_PASSWORD" \
                    '{token: $token, hostname: $hostname, admin_password: $admin_password}')" \
      --region ${var.aws_region}
    EOT
  }
}

# Create AWS Secret for the token and admin password
resource "aws_secretsmanager_secret" "argocd" {
  name = "argocd/credentials"
  force_overwrite_replica_secret = true
  recovery_window_in_days        = 0
  tags = var.tags
}

# Store initial empty values
resource "aws_secretsmanager_secret_version" "argocd" {
  secret_id     = aws_secretsmanager_secret.argocd.id
  secret_string = jsonencode(var.argocd_secret)
}