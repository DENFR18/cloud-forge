data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ─── IAM Role EC2 (SSM + ECR) ─────────────────────────────────────────────────
resource "aws_iam_role" "k3s" {
  name = "role-${var.project}-k3s-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "k3s" {
  name = "policy-${var.project}-k3s-${var.environment}"
  role = aws_iam_role.k3s.id

  # ecr:GetAuthorizationToken ne supporte que Resource="*" (limitation AWS).
  # Les actions ECR de lecture sont restreintes aux repos du projet.
  # checkov:skip=CKV_AWS_355:ecr:GetAuthorizationToken requires wildcard by AWS design
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SSMParameters"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:PutParameter",
          "ssm:DeleteParameter"
        ]
        Resource = "arn:aws:ssm:${var.aws_region}:*:parameter/${var.project}/*"
      },
      {
        Sid      = "EcrAuthToken"
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Sid    = "EcrPull"
        Effect = "Allow"
        Action = [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability"
        ]
        Resource = "arn:aws:ecr:${var.aws_region}:*:repository/${var.project}/*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "k3s" {
  name = "profile-${var.project}-k3s-${var.environment}"
  role = aws_iam_role.k3s.name
}

# ─── Security Group ───────────────────────────────────────────────────────────
# SSH/HTTP/NodePort ouverts sur 0.0.0.0/0 : projet pédagogique Free Tier sans bastion.
resource "aws_security_group" "k3s" {
  # checkov:skip=CKV_AWS_24:SSH open to 0.0.0.0/0 — no bastion in Free Tier setup
  # checkov:skip=CKV_AWS_260:HTTP open to 0.0.0.0/0 — public web endpoints expected
  # checkov:skip=CKV_AWS_382:wide egress — needed for k3s install and ECR pulls
  name        = "k3s-${var.project}-${var.environment}"
  description = "Security group for k3s cluster (master + workers)"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "k3s API Server"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS"
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "NodePort Services"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Inter-node communication"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Internet access for k3s install, updates and ECR pulls"
  }

  tags = merge(var.tags, { Name = "k3s-${var.project}-${var.environment}" })
}

# ─── Master EIP (allouée avant l'instance pour que l'adresse soit connue au démarrage) ──
resource "aws_eip" "master" {
  domain = "vpc"
  tags   = merge(var.tags, { Name = "eip-master-${var.project}-${var.environment}" })
}

# ─── Master Node ──────────────────────────────────────────────────────────────
# Public IP requis : le master est point d'entrée du cluster et de l'API k3s.
resource "aws_instance" "master" {
  # checkov:skip=CKV_AWS_88:public IP required to expose k3s API and ingress
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.small"
  subnet_id                   = var.public_subnet_ids[0]
  vpc_security_group_ids      = [aws_security_group.k3s.id]
  iam_instance_profile        = aws_iam_instance_profile.k3s.name
  associate_public_ip_address = true
  ebs_optimized               = true
  monitoring                  = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 20
  }

  user_data = base64encode(templatefile("${path.module}/templates/master.sh.tpl", {
    region     = var.aws_region
    project    = var.project
    master_eip = aws_eip.master.public_ip
  }))

  tags = merge(var.tags, {
    Name = "k3s-master-${var.project}-${var.environment}"
    Role = "master"
  })
}

resource "aws_eip_association" "master" {
  instance_id   = aws_instance.master.id
  allocation_id = aws_eip.master.id
}

# ─── Worker Nodes ─────────────────────────────────────────────────────────────
resource "aws_instance" "workers" {
  # checkov:skip=CKV_AWS_88:public IP required for k3s worker to pull ECR images directly
  count                       = 2
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = var.public_subnet_ids[count.index % length(var.public_subnet_ids)]
  vpc_security_group_ids      = [aws_security_group.k3s.id]
  iam_instance_profile        = aws_iam_instance_profile.k3s.name
  associate_public_ip_address = true
  ebs_optimized               = true
  monitoring                  = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 20
  }

  user_data = base64encode(templatefile("${path.module}/templates/worker.sh.tpl", {
    region  = var.aws_region
    project = var.project
  }))

  tags = merge(var.tags, {
    Name = "k3s-worker-${count.index + 1}-${var.project}-${var.environment}"
    Role = "worker"
  })
}
