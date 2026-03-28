output "cluster_id" {
  description = "Kapsule cluster ID"
  value       = module.kapsule.cluster_id
}

output "cluster_apiserver_url" {
  description = "Kapsule API server URL"
  value       = module.kapsule.apiserver_url
}

output "kubeconfig" {
  description = "Kubeconfig to access the cluster"
  value       = module.kapsule.kubeconfig
  sensitive   = true
}

output "registry_endpoint" {
  description = "Container registry endpoint"
  value       = module.registry.endpoint
}
