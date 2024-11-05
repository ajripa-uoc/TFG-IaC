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