variable "project" {
  description = "Project name"
  type        = string
}

variable "postgres_password" {
  description = "PostgreSQL password for Backstage"
  type        = string
  sensitive   = true
}

variable "github_token" {
  description = "GitHub Personal Access Token for Backstage catalog discovery"
  type        = string
  sensitive   = true
}

variable "github_client_id" {
  description = "GitHub OAuth App client ID"
  type        = string
  sensitive   = true
}

variable "github_client_secret" {
  description = "GitHub OAuth App client secret"
  type        = string
  sensitive   = true
}

variable "kube_api_url" {
  description = "Kubernetes API server URL for the Backstage Kubernetes plugin"
  type        = string
}

variable "kube_sa_token" {
  description = "Service account token for the Backstage Kubernetes plugin"
  type        = string
  sensitive   = true
  default     = ""
}

variable "argocd_password" {
  description = "ArgoCD admin password for the Backstage ArgoCD plugin"
  type        = string
  sensitive   = true
  default     = ""
}

variable "backstage_base_url" {
  description = "Public base URL for Backstage including protocol (e.g. http://backstage.<LB_IP>.nip.io)"
  type        = string
  default     = "http://backstage.placeholder.nip.io"
}

variable "quota_requests_cpu" {
  description = "ResourceQuota requests.cpu"
  type        = string
  default     = "1"
}

variable "quota_requests_memory" {
  description = "ResourceQuota requests.memory"
  type        = string
  default     = "1Gi"
}

variable "quota_limits_cpu" {
  description = "ResourceQuota limits.cpu"
  type        = string
  default     = "2"
}

variable "quota_limits_memory" {
  description = "ResourceQuota limits.memory"
  type        = string
  default     = "2Gi"
}

variable "postgres_storage" {
  description = "PVC size for PostgreSQL"
  type        = string
  default     = "5Gi"
}
