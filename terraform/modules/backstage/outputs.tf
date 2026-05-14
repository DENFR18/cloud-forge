output "namespace" {
  description = "Backstage Kubernetes namespace"
  value       = kubernetes_namespace.backstage.metadata[0].name
}

output "secret_name" {
  description = "Name of the Kubernetes secret holding Backstage credentials"
  value       = kubernetes_secret.backstage_credentials.metadata[0].name
}

output "postgres_pvc_name" {
  description = "Name of the PostgreSQL PVC"
  value       = kubernetes_persistent_volume_claim.postgres.metadata[0].name
}
