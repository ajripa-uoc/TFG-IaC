# Deploy the argocd-apps Helm chart to set up the ArgoCD App-of-Apps.
# This follows the "App of Apps" pattern in ArgoCD, where a parent ArgoCD application manages multiple child applications.
# Using this pattern enables centralized control, allowing ArgoCD to manage multiple applications from a single root application configuration.
# Reference: https://artifacthub.io/packages/helm/argo/argocd-apps
resource "helm_release" "argocd-apps" {
  depends_on       = [helm_release.argocd]
  name             = "argocd-apps"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argocd-apps"
  version          = "2.0.2"
  namespace        = "argocd-apps"
  create_namespace = true

  values = [templatefile("templates/argocd-apps.yaml.tpl", {
    github_repo_url = var.github_repo_url
  })]
}