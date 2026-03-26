output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
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
