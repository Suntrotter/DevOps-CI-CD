terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

#################################
#  S3 + DynamoDB backend
#################################
module "s3_backend" {
  source           = "./modules/s3-backend"
  bucket_name      = var.bucket_name
  table_name       = var.table_name
  create_resources = var.create_backend_resources
}

#################################
#  VPC
#################################
module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = var.vpc_cidr_block
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
  vpc_name           = "lesson-5-vpc"
}

#################################
#  ECR
#################################
module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = var.ecr_name
  scan_on_push = true
}

#################################
#  EKS
#################################
module "eks" {
  source = "./modules/eks"

  project_name       = var.project_name            # додай цю змінну в root variables.tf
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  aws_region         = var.aws_region
  ecr_repo_arn       = module.ecr.repository_arn   # дивись outputs у modules/ecr/outputs.tf
  kubernetes_version = "1.29"                      # або варіантом через var.kubernetes_version
}


#################################
#  RDS / Aurora (універсальний модуль)
#################################
module "rds" {
  source = "./modules/rds"

  name_prefix = "lesson-db"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  # доступ до БД з усього VPC (для демо / домашки)
  allowed_cidr_blocks = [var.vpc_cidr_block]

  # перемикач: false -> звичайна RDS, true -> Aurora
  use_aurora             = false
  engine                 = "postgres"
  engine_version         = "14.9"
  parameter_group_family = "postgres14"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  multi_az               = false

  db_name  = "appdb"
  username = "appuser"
  password = var.db_password    # ДОДАЙ var.db_password у root variables.tf
  port     = 5432
}

#################################
#  Jenkins (Helm-модуль)
#################################
module "jenkins" {
  source = "./modules/jenkins"

  cluster_name     = module.eks.cluster_name
  region           = var.aws_region
  namespace        = "jenkins"

  cluster_endpoint = module.eks.cluster_endpoint
  cluster_ca_cert  = module.eks.cluster_ca_cert
  token            = module.eks.token
}

#################################
#  Argo CD (Helm-модуль)
#################################
module "argo_cd" {
  source = "./modules/argo_cd"

  cluster_name     = module.eks.cluster_name
  region           = var.aws_region

  cluster_endpoint = module.eks.cluster_endpoint
  cluster_ca_cert  = module.eks.cluster_ca_cert

  namespace     = "argocd"
  chart_version = "7.6.9"
}

#################################
#  Monitoring (Prometheus + Grafana)
#################################
module "monitoring" {
  source = "./modules/monitoring"

  cluster_name     = module.eks.cluster_name
  region           = var.aws_region
  cluster_endpoint = module.eks.cluster_endpoint
  cluster_ca_cert  = module.eks.cluster_ca_cert
  token            = module.eks.token

  namespace     = "monitoring"
  chart_version = "58.3.0"
}

