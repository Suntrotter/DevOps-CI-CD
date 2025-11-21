resource "aws_rds_cluster" "this" {
  count              = var.use_aurora ? 1 : 0
  cluster_identifier = "${var.name_prefix}-aurora-cluster"

  engine         = var.engine
  engine_version = var.engine_version

  database_name   = var.db_name
  master_username = var.username
  master_password = var.password
  port            = var.port

  db_subnet_group_name             = aws_db_subnet_group.this.name
  vpc_security_group_ids           = [aws_security_group.this.id]
  db_cluster_parameter_group_name  = one(aws_rds_cluster_parameter_group.aurora[*].name)

  skip_final_snapshot = var.skip_final_snapshot
  deletion_protection = false

  tags = {
    Name = "${var.name_prefix}-aurora-cluster"
  }
}

resource "aws_rds_cluster_instance" "this" {
  count = var.use_aurora ? 1 : 0

  identifier         = "${var.name_prefix}-aurora-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.this[0].id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.this[0].engine

  publicly_accessible = false
  db_subnet_group_name = aws_db_subnet_group.this.name

  tags = {
    Name = "${var.name_prefix}-aurora-instance-${count.index}"
  }
}
