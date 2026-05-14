terraform {
  required_version = ">= 1.5.0"
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "scaleway" {
  zone   = "${var.scw_region}-1"
  region = var.scw_region
}

provider "kubernetes" {
  host = module.kapsule.apiserver_url
  cluster_ca_certificate = base64decode(
    yamldecode(module.kapsule.kubeconfig)["clusters"][0]["cluster"]["certificate-authority-data"]
  )
  token = yamldecode(module.kapsule.kubeconfig)["users"][0]["user"]["token"]
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

# --- Backstage prerequisites (namespace, secret, PVC) ---
# Run terraform apply -target=module.kapsule -target=module.registry first,
# then terraform apply to provision these Kubernetes resources.
module "backstage" {
  source = "./modules/backstage"

  project              = var.project
  postgres_password    = var.backstage_postgres_password
  github_token         = var.backstage_github_token
  github_client_id     = var.backstage_github_client_id
  github_client_secret = var.backstage_github_client_secret
  kube_api_url         = module.kapsule.apiserver_url
  kube_sa_token        = var.backstage_kube_sa_token
  argocd_password      = var.backstage_argocd_password
  backstage_base_url   = var.backstage_base_url
  backend_secret       = var.backstage_backend_secret

  depends_on = [module.kapsule]
}
