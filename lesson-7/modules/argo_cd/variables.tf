variable "cluster_name" {
  type = string
}

variable "cluster_endpoint" {
  type        = string
  description = "EKS API endpoint"
}

variable "cluster_ca_cert" {
  type        = string
  description = "EKS cluster CA cert (base64)"
}

variable "namespace" {
  type    = string
  default = "argocd"
}

variable "chart_version" {
  type    = string
  default = "7.6.9" # любая актуальная версия, нам важно только наличие
}

variable "region" {
  type = string
}
