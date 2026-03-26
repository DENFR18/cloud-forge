output "master_public_ip" {
  description = "IP publique du master k3s"
  value       = module.k3s.master_public_ip
}

output "ecr_node_api_url" {
  description = "ECR URL for node-api"
  value       = module.ecr.node_api_url
}

output "ecr_flask_api_url" {
  description = "ECR URL for flask-api"
  value       = module.ecr.flask_api_url
}

output "ecr_react_url" {
  description = "ECR URL for react app"
  value       = module.ecr.react_url
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}
