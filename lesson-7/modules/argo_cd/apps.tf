# resource "helm_release" "argocd_apps" {
#   name       = "argocd-apps"
#   namespace  = var.namespace
#   repository = "https://argoproj.github.io/argo-helm"
#   chart      = "argocd-apps"
#   version    = var.chart_version
#
#   values = [
#     file("${path.module}/apps-values.yaml")
#   ]
# }
