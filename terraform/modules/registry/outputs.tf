output "endpoint" {
  description = "Registry endpoint URL"
  value       = scaleway_registry_namespace.this.endpoint
}

output "id" {
  description = "Registry namespace ID"
  value       = scaleway_registry_namespace.this.id
}
