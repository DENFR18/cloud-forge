output "node_api_url" {
  value = aws_ecr_repository.node_api.repository_url
}

output "flask_api_url" {
  value = aws_ecr_repository.flask_api.repository_url
}

output "react_url" {
  value = aws_ecr_repository.react.repository_url
}
