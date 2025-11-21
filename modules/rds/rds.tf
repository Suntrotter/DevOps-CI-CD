resource "aws_db_instance" "this" {
  count = var.use_aurora ? 0 : 1

  identifier = "${var.name_prefix}-rds"

  allocated_storage = var.allocated_storage
  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class

  db_name  = var.db_name
  username = var.username
  password = var.password
  port     = var.port

  multi_az             = var.multi_az
  db_subnet_group_name = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  parameter_group_name   = one(aws_db_parameter_group.this[*].name)

  publicly_accessible = false
  skip_final_snapshot = var.skip_final_snapshot
  deletion_protection = false

  tags = {
    Name = "${var.name_prefix}-rds"
  }
}
