variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "cluster_endpoint" {
  type        = string
  description = "EKS cluster endpoint"
}

variable "cluster_ca_cert" {
  type        = string
  description = "EKS cluster CA certificate (base64)"
}

variable "token" {
  type        = string
  description = "EKS auth token"
}

variable "namespace" {
  type        = string
  description = "Namespace for monitoring stack"
  default     = "monitoring"
}

variable "chart_version" {
  type        = string
  description = "kube-prometheus-stack chart version"
  default     = "58.3.0"
}
