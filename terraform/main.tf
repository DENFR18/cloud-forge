terraform {
  required_version = ">= 1.5.0"
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "~> 2.0"
    }
  }
}

provider "scaleway" {
  zone   = "${var.scw_region}-1"
  region = var.scw_region
}

locals {
  tags = [
    "project=${var.project}",
    "environment=${var.environment}",
    "managed_by=terraform",
  ]
}

# --- Private Network ---
resource "scaleway_vpc_private_network" "this" {
  name = "${var.project}-${var.environment}"
  tags = local.tags
}

# --- Kapsule Cluster ---
module "kapsule" {
  source             = "./modules/kapsule"
  project            = var.project
  environment        = var.environment
  tags               = local.tags
  private_network_id = scaleway_vpc_private_network.this.id
}

# --- Container Registry ---
module "registry" {
  source      = "./modules/registry"
  project     = var.project
  environment = var.environment
}
