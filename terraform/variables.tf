variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-3"
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
