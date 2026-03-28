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
