# KMS encryption pour ECR (CKV_AWS_136)
# image_tag_mutability = "MUTABLE" : requis pour re-pusher les tags `:latest`
# depuis le workflow apps. checkov:skip=CKV_AWS_51

resource "aws_ecr_repository" "node_api" {
  name                 = "${var.project}/node-api"
  image_tag_mutability = "MUTABLE" # checkov:skip=CKV_AWS_51:mutable tags required for :latest rollout
  force_delete         = true

  encryption_configuration {
    encryption_type = "KMS"
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}

resource "aws_ecr_repository" "flask_api" {
  name                 = "${var.project}/flask-api"
  image_tag_mutability = "MUTABLE" # checkov:skip=CKV_AWS_51:mutable tags required for :latest rollout
  force_delete         = true

  encryption_configuration {
    encryption_type = "KMS"
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}

resource "aws_ecr_repository" "react" {
  name                 = "${var.project}/react"
  image_tag_mutability = "MUTABLE" # checkov:skip=CKV_AWS_51:mutable tags required for :latest rollout
  force_delete         = true

  encryption_configuration {
    encryption_type = "KMS"
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}
