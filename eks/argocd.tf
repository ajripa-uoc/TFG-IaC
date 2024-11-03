# Deploy ArgoCD using Helm, a package manager for Kubernetes applications.
# ArgoCD is a declarative GitOps tool for continuous deployment of applications to Kubernetes.
# The Helm chart used here can be found on Artifact Hub, which provides pre-configured options
# for installing and managing ArgoCD.
# Reference: https://artifacthub.io/packages/helm/argo/argo-cd


# Deploy the ArgoCD Helm chart with the specified values
resource "helm_release" "argocd" {
  depends_on = [
    helm_release.aws_alb_controller,
    helm_release.external_dns
  ]
  name       = "argocd"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  version    = "7.6.12"
  timeout    = "1500"
  create_namespace = true
  namespace  = "argocd"

  values  = [templatefile("templates/argocd.yaml.tpl", {
    argocd_admin_user           = var.argocd_admin_user,
    github_app_id               = var.github_app_id,
    github_app_client_id        = var.github_app_client_id,
    github_app_client_secret    = var.github_app_secret,
    github_app_installation_id  = var.github_app_installation_id,
    github_app_url              = var.github_app_url,
    github_app_private_key      = var.github_app_private_key,
    domain_name                 = "argocd.${var.domain_name}"
  })]
}

# Create a Kubernetes secret to store the GitHub App credentials
resource "kubernetes_secret" "github_app_creds" {
  depends_on = [ helm_release.argocd ]
  metadata {
    name      = "github-app-creds"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repo-creds"
    }
  }

  data = {
    type                    = "git"
    url                     = var.github_app_url
    githubAppID             = base64encode(var.github_app_id)
    githubAppInstallationID = base64encode(var.github_app_installation_id)
    githubAppPrivateKey     = base64encode(var.github_app_private_key)
  }
}
