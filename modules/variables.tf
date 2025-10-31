variable "region" {
  type    = string
  default = "us-west-2"
}

# Backend names 
variable "bucket_name"  { type = string  default = "my-awesome-lesson5-bucket" }
variable "table_name"   { type = string  default = "terraform-locks" }
variable "create_backend_resources" {
  type    = bool
  default = false
}

# VPC
variable "vpc_cidr_block"     { type = string  default = "10.0.0.0/16" }
variable "public_subnets"     { type = list(string) default = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"] }
variable "private_subnets"    { type = list(string) default = ["10.0.4.0/24","10.0.5.0/24","10.0.6.0/24"] }
variable "availability_zones" { type = list(string) default = ["us-west-2a","us-west-2b","us-west-2c"] }

# ECR
variable "ecr_name" { type = string default = "lesson-5-ecr" }
