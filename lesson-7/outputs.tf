output "ecr_repo_url" {
  value = module.ecr.repo_url
}

output "ecr_repo_arn" {
  value = module.ecr.repo_arn
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_ca_cert" {
  value = module.eks.cluster_ca_cert
}

