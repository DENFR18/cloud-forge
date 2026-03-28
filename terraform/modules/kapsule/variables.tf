variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "scw_region" {
  description = "Scaleway region"
  type        = string
}

variable "tags" {
  description = "Tags"
  type        = list(string)
}

variable "private_network_id" {
  description = "Private network ID for the cluster"
  type        = string
}
