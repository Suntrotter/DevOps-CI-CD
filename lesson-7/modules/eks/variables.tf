variable "project_name" { type = string }
variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "aws_region" { type = string }
variable "ecr_repo_arn" { type = string }

variable "kubernetes_version" {
  type    = string
  default = "1.29"
}
