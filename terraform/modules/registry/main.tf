terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }
  }
}

resource "scaleway_registry_namespace" "this" {
  name        = "${var.project}-${var.environment}"
  description = "Container registry for ${var.project}"
  is_public   = false
}
