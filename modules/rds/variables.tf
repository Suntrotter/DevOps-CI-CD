variable "use_aurora" {
  type        = bool
  description = "If true, create Aurora cluster, otherwise a single RDS instance."
  default     = false
}

variable "name_prefix" {
  type        = string
  description = "Prefix for naming RDS resources (cluster, instance, SG, etc.)."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where DB will be created."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for DB subnet group."
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks allowed to connect to DB."
  default     = []
}

variable "engine" {
  type        = string
  description = "Database engine. Example: postgres, aurora-postgresql."
  default     = "postgres"
}

variable "engine_version" {
  type        = string
  description = "Database engine version."
  default     = "14.9"
}

variable "instance_class" {
  type        = string
  description = "Instance class for RDS or Aurora instances."
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  type        = number
  description = "Allocated storage in GB (only for non-Aurora)."
  default     = 20
}

variable "multi_az" {
  type        = bool
  description = "Enable Multi-AZ for RDS instance."
  default     = false
}

variable "db_name" {
  type        = string
  description = "Initial database name."
  default     = "appdb"
}

variable "username" {
  type        = string
  description = "Master username."
  default     = "appuser"
}

variable "password" {
  type        = string
  description = "Master password."
  sensitive   = true
}

variable "port" {
  type        = number
  description = "Database port."
  default     = 5432
}

variable "parameter_group_family" {
  type        = string
  description = "Parameter group family, e.g. postgres14 or aurora-postgresql14."
  default     = "postgres14"
}

variable "param_max_connections" {
  type        = number
  description = "Value for max_connections parameter."
  default     = 100
}

variable "param_log_statement" {
  type        = string
  description = "Value for log_statement parameter."
  default     = "none"
}

variable "param_work_mem" {
  type        = string
  description = "Value for work_mem parameter."
  default     = "4MB"
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Skip final snapshot on destroy."
  default     = true
}
