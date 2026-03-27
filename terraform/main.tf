terraform {
  required_version = ">= 1.5.0"
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

locals {
  tags = {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  }
}

module "vpc" {
  source      = "./modules/vpc"
  project     = var.project
  environment = var.environment
  tags        = local.tags
}

module "k3s" {
  source            = "./modules/k3s"
  project           = var.project
  environment       = var.environment
  aws_region        = var.aws_region
  tags              = local.tags
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  public_key        = var.public_key
}

module "ecr" {
  source      = "./modules/ecr"
  project     = var.project
  environment = var.environment
  tags        = local.tags
}
