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
  region = var.region
}

# S3 + DynamoDB 
module "s3_backend" {
  source            = "./modules/s3-backend"
  bucket_name       = var.bucket_name
  table_name        = var.table_name
  create_resources  = var.create_backend_resources
}

# VPC
module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = var.vpc_cidr_block
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones
  vpc_name           = "lesson-5-vpc"
}

# ECR 
module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = var.ecr_name
  scan_on_push = true
}
