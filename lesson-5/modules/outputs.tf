output "s3_backend_bucket" {
  value = module.s3_backend.bucket_id != null ? module.s3_backend.bucket_id : "existing-bucket-used"
}

output "dynamodb_table" {
  value = module.s3_backend.table_name != null ? module.s3_backend.table_name : "existing-table-used"
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}
