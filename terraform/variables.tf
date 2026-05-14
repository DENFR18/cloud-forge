variable "scw_region" {
  description = "Scaleway region"
  type        = string
  default     = "fr-par"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "cloud-forge"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "prod"
}

# --- Backstage credentials (sensitive) ---

variable "backstage_github_client_id" {
  description = "GitHub OAuth App client ID for Backstage"
  type        = string
  sensitive   = true
  default     = ""
}

variable "backstage_github_client_secret" {
  description = "GitHub OAuth App client secret for Backstage"
  type        = string
  sensitive   = true
  default     = ""
}

variable "backstage_github_token" {
  description = "GitHub PAT for Backstage catalog discovery"
  type        = string
  sensitive   = true
  default     = ""
}

variable "backstage_postgres_password" {
  description = "PostgreSQL password for Backstage"
  type        = string
  sensitive   = true
  default     = ""
}

variable "backstage_kube_sa_token" {
  description = "Service account token for Backstage Kubernetes plugin (set after cluster creation)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "backstage_argocd_password" {
  description = "ArgoCD admin password for Backstage ArgoCD plugin (set after ArgoCD deployment)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "backstage_base_url" {
  description = "Public base URL for Backstage including protocol (e.g. http://backstage.<LB_IP>.nip.io)"
  type        = string
  default     = "http://backstage.placeholder.nip.io"
}

variable "backstage_backend_secret" {
  description = "Backstage backend signing key for internal plugin-to-plugin auth"
  type        = string
  sensitive   = true
  default     = ""
}
