# Universal RDS Module

Цей модуль створює ресурси для роботи з базою даних у AWS:

- **Aurora Cluster** (PostgreSQL) **або** звичайну **RDS instance** – через перемикач `use_aurora`;
- `aws_db_subnet_group` для приватних підмереж;
- `aws_security_group` з доступом до порта БД;
- parameter group з базовими параметрами (`max_connections`, `log_statement`, `work_mem`).

Модуль написаний так, щоб його можна було використовувати багаторазово з мінімальними змінами змінних.

---

## Використання

### 1. Звичайна RDS (PostgreSQL)

```hcl
module "rds" {
  source = "./modules/rds"

  name_prefix = "devops-ci-cd-db"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  allowed_cidr_blocks = [module.vpc.vpc_cidr]

  use_aurora = false

  engine                 = "postgres"
  engine_version         = "14.9"
  parameter_group_family = "postgres14"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  multi_az               = false

  db_name  = "appdb"
  username = "appuser"
  password = "ChangeMe123!@"  

  port = 5432
}
