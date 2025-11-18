output "argocd_namespace" {
  value = var.namespace
}

output "argocd_server_service" {
  description = "Argo CD server service name"
  value       = "argo-cd-argocd-server"
}
