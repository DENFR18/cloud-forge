terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
}

resource "scaleway_k8s_cluster" "this" {
  name    = "${var.project}-${var.environment}"
  version = "1.31"
  cni     = "cilium"
  tags    = var.tags

  private_network_id = var.private_network_id

  delete_additional_resources = true

  auto_upgrade {
    enable                        = true
    maintenance_window_start_hour = 3
    maintenance_window_day        = "sunday"
  }
}

resource "scaleway_k8s_pool" "workers" {
  cluster_id  = scaleway_k8s_cluster.this.id
  name        = "workers"
  node_type   = "DEV1-M"
  size        = 2
  min_size    = 2
  max_size    = 3
  autoscaling = true
  autohealing = true
  tags        = var.tags

  upgrade_policy {
    max_unavailable = 1
    max_surge       = 1
  }
}
