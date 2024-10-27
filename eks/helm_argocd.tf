# resource "kubernetes_namespace" "argocd" {
#   metadata {
#     name = "argocd"
#   }
# }

# resource "helm_release" "argocd" {
#   name       = "argocd"
#   chart      = "argo-cd"
#   repository = "https://argoproj.github.io/argo-helm"
#   version    = "7.6.12"
#   timeout    = "1500"
#   namespace  = kubernetes_namespace.argocd.id
#   values = [data.template_file.argo-values.rendered]
# }

# resource "null_resource" "password" {
#   provisioner "local-exec" {
#     working_dir = "./argocd"
#     command     = "kubectl -n argocd-staging get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d > argocd-login.txt"
#   }
# }

# resource "null_resource" "del-argo-pass" {
#   depends_on = [null_resource.password]
#   provisioner "local-exec" {
#     command = "kubectl -n argocd-staging delete secret argocd-initial-admin-secret"
#   }
# }