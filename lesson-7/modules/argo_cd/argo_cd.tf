resource "helm_release" "argocd" {
  name       = "argo-cd"
  namespace  = var.namespace
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version

  create_namespace = true

  values = [
    file("${path.module}/values.yaml")
  ]

  timeout = 1200
}


