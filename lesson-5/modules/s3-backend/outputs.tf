

output "bucket_id" {
  
  value       = var.create_resources ? aws_s3_bucket.state[0].id : null
  description = "ID of the S3 state bucket (null if using an existing bucket)."
}

output "table_name" {
  
  value       = var.create_resources ? aws_dynamodb_table.locks[0].name : null
  description = "Name of the DynamoDB locks table (null if using an existing table)."
}
