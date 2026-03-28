output "cluster_id" {
  description = "Kapsule cluster ID"
  value       = scaleway_k8s_cluster.this.id
}

output "apiserver_url" {
  description = "Kapsule API server URL"
  value       = scaleway_k8s_cluster.this.apiserver_url
}

output "kubeconfig" {
  description = "Kubeconfig content"
  value       = scaleway_k8s_cluster.this.kubeconfig[0].config_file
  sensitive   = true
}
