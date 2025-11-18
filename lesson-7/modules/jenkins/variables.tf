variable "cluster_name" {
  type = string
}

variable "region" {
  type = string
}

variable "namespace" {
  type    = string
  default = "jenkins"
}

variable "name" {
  type    = string
  default = "jenkins"
}

variable "chart_version" {
  type    = string
  default = "5.0.20"
}

variable "cluster_endpoint" {
  description = "EKS API endpoint"
  type        = string
}

variable "cluster_ca_cert" {
  description = "EKS cluster CA certificate (base64)"
  type        = string
}

variable "token" {
  description = "Auth token for Kubernetes API"
  type        = string
}
