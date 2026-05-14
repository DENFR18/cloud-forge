terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

resource "kubernetes_namespace" "backstage" {
  metadata {
    name = "backstage"
    labels = {
      project    = var.project
      managed_by = "terraform"
    }
  }
}

resource "kubernetes_resource_quota" "backstage" {
  metadata {
    name      = "quota"
    namespace = kubernetes_namespace.backstage.metadata[0].name
  }
  spec {
    hard = {
      "requests.cpu"    = var.quota_requests_cpu
      "requests.memory" = var.quota_requests_memory
      "limits.cpu"      = var.quota_limits_cpu
      "limits.memory"   = var.quota_limits_memory
    }
  }
}

resource "kubernetes_secret" "backstage_credentials" {
  metadata {
    name      = "backstage-credentials"
    namespace = kubernetes_namespace.backstage.metadata[0].name
  }
  type = "Opaque"
  data = {
    POSTGRES_PASSWORD    = var.postgres_password
    GITHUB_TOKEN         = var.github_token
    GITHUB_CLIENT_ID     = var.github_client_id
    GITHUB_CLIENT_SECRET = var.github_client_secret
    KUBE_API_URL         = var.kube_api_url
    KUBE_SA_TOKEN        = var.kube_sa_token
    ARGOCD_PASSWORD      = var.argocd_password
    BACKSTAGE_BASE_URL   = var.backstage_base_url
    BACKEND_SECRET       = var.backend_secret
  }
}

resource "kubernetes_persistent_volume_claim" "postgres" {
  metadata {
    name      = "backstage-postgres-pvc"
    namespace = kubernetes_namespace.backstage.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.postgres_storage
      }
    }
  }
  wait_until_bound = false
}
