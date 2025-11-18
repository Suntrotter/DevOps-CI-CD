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

############################
# VPC (з модуля lesson-5)
############################
module "vpc" {
  source = "../modules/vpc"

  vpc_name       = "${var.project_name}-vpc"
  vpc_cidr_block = "10.0.0.0/16"

  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

  availability_zones = ["eu-north-1a", "eu-north-1b"]
}

############################
# ECR
############################
module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "${var.project_name}-ecr"
  scan_on_push = true
}

############################
# EKS (локальний модуль lesson-7/modules/eks)
############################
module "eks" {
  source = "./modules/eks"

  project_name = var.project_name
  aws_region   = var.aws_region

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids

  ecr_repo_arn = module.ecr.repo_arn
}


############################
# Jenkins (модуль з modules/jenkins)
############################
module "jenkins" {
  source = "./modules/jenkins"

  cluster_name  = module.eks.cluster_name
  region        = var.aws_region
  namespace     = "jenkins"
  chart_version = "5.0.20"


  cluster_endpoint = module.eks.cluster_endpoint
  cluster_ca_cert  = module.eks.cluster_ca_cert
  token            = module.eks.token
}

module "argo_cd" {
  source = "./modules/argo_cd"

  region           = var.aws_region
  cluster_name     = module.eks.cluster_name
  cluster_endpoint = module.eks.cluster_endpoint
  cluster_ca_cert  = module.eks.cluster_ca_cert

  namespace     = "argocd"
  chart_version = "7.6.9"
}



