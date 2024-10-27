# Deploy ArgoCD using Helm, a package manager for Kubernetes applications.
# ArgoCD is a declarative GitOps tool for continuous deployment of applications to Kubernetes.
# The Helm chart used here can be found on Artifact Hub, which provides pre-configured options
# for installing and managing ArgoCD.
# Reference: https://artifacthub.io/packages/helm/argo/argo-cd

# Create a Kubernetes namespace for ArgoCD
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

# Deploy the ArgoCD Helm chart with the specified values
resource "helm_release" "argocd" {
  name       = "argocd"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  version    = "7.6.12"
  timeout    = "1500"
  namespace  = kubernetes_namespace.argocd.id
  values  = [templatefile("templates/argocd.yaml.tpl", {
    clientid      = var.github.clientid,
    clientsecret  = var.github.clientsecret
  })]
}

# Retrieve the initial admin password for ArgoCD
resource "null_resource" "argocd_get_pass" {
  depends_on = [helm_release.argocd]  # Ensures this runs after the Helm release is created
  provisioner "local-exec" {
    working_dir = "./helpers"
    command     = "kubectl -n ${kubernetes_namespace.argocd.id} argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d > argocd-initial-password.txt"
  }
}

# Delete the initial admin password secret after retrieving the password
resource "null_resource" "argocd_del_pass" {
  depends_on = [null_resource.argocd_get_pass]
  provisioner "local-exec" {
    command = "kubectl -n ${kubernetes_namespace.argocd.id} delete secret argocd-initial-admin-secret"
  }
}

