resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-db-subnets"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.name_prefix}-db-subnets"
  }
}

resource "aws_security_group" "this" {
  name        = "${var.name_prefix}-db-sg"
  description = "Security group for RDS / Aurora"
  vpc_id      = var.vpc_id

  ingress {
    description = "DB access"
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-db-sg"
  }
}

# Parameter group for звичайної RDS
resource "aws_db_parameter_group" "this" {
  count  = var.use_aurora ? 0 : 1
  name   = "${var.name_prefix}-rds-params"
  family = var.parameter_group_family

  parameter {
    name  = "max_connections"
    value = tostring(var.param_max_connections)
  }

  parameter {
    name  = "log_statement"
    value = var.param_log_statement
  }

  parameter {
    name  = "work_mem"
    value = var.param_work_mem
  }

  tags = {
    Name = "${var.name_prefix}-rds-params"
  }
}

# Parameter group для Aurora
resource "aws_rds_cluster_parameter_group" "aurora" {
  count  = var.use_aurora ? 1 : 0
  name   = "${var.name_prefix}-aurora-params"
  family = var.parameter_group_family

  parameter {
    name  = "max_connections"
    value = tostring(var.param_max_connections)
  }

  parameter {
    name  = "log_statement"
    value = var.param_log_statement
  }

  parameter {
    name  = "work_mem"
    value = var.param_work_mem
  }

  tags = {
    Name = "${var.name_prefix}-aurora-params"
  }
}
