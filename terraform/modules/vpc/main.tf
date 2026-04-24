data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = merge(var.tags, { Name = "vpc-${var.project}-${var.environment}" })
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "igw-${var.project}-${var.environment}" })
}

# Restrict the default security group to deny all traffic (CKV2_AWS_12)
resource "aws_default_security_group" "main" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "default-${var.project}-${var.environment}" })
}

# ─── VPC Flow Logs (CKV2_AWS_11) ─────────────────────────────────────────────
# Rétention 7j et chiffrement AWS-owned pour limiter les coûts Free Tier.
resource "aws_cloudwatch_log_group" "flow" {
  # checkov:skip=CKV_AWS_158:no custom KMS key — default AWS-managed encryption
  # checkov:skip=CKV_AWS_338:7-day retention chosen for Free Tier cost constraints
  name              = "/aws/vpc/flow/${var.project}-${var.environment}"
  retention_in_days = 7
  tags              = var.tags
}

resource "aws_iam_role" "flow" {
  name = "role-${var.project}-vpc-flow-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "flow" {
  name = "policy-${var.project}-vpc-flow-${var.environment}"
  role = aws_iam_role.flow.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Resource = "${aws_cloudwatch_log_group.flow.arn}:*"
    }]
  })
}

resource "aws_flow_log" "main" {
  iam_role_arn    = aws_iam_role.flow.arn
  log_destination = aws_cloudwatch_log_group.flow.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id
  tags            = var.tags
}

# ─── Public Subnets uniquement (pas de NAT Gateway = pas de couts) ────────────
# map_public_ip_on_launch = false : les instances qui ont besoin d'une IP publique
# l'attribuent explicitement via associate_public_ip_address (CKV_AWS_130)
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "subnet-public-${count.index + 1}-${var.project}-${var.environment}"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(var.tags, { Name = "rtb-public-${var.project}-${var.environment}" })
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
