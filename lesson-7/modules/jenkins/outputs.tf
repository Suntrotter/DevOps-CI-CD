output "jenkins_service" {
  description = "Jenkins service DNS name"
  value       = "jenkins.${var.namespace}.svc.cluster.local"
}
