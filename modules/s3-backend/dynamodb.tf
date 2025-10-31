resource "aws_dynamodb_table" "locks" {
  count        = var.create_resources ? 1 : 0
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
