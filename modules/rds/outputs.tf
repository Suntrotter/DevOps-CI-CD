output "db_endpoint" {
  description = "Primary endpoint of the database (RDS instance or Aurora cluster)."
  value       = var.use_aurora ? aws_rds_cluster.this[0].endpoint : aws_db_instance.this[0].address
}

output "db_port" {
  description = "Database port."
  value       = var.port
}

output "db_security_group_id" {
  description = "Security group ID used by DB."
  value       = aws_security_group.this.id
}

output "db_subnet_group_name" {
  description = "DB subnet group name."
  value       = aws_db_subnet_group.this.name
}
