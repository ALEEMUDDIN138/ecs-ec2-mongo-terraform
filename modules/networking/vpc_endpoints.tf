#############################################
# VPC Endpoints for ECR & S3 (Final Version)
#############################################

data "aws_region" "current" {}

# Security group for interface endpoints
resource "aws_security_group" "vpce_sg" {
  name        = "${var.project_name}-vpce-sg"
  description = "Allow ECS tasks to reach VPC interface endpoints"
  vpc_id      = aws_vpc.main.id  # ✅ internal reference

  ingress {
    description     = "Allow ECS tasks to communicate with endpoints"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [var.ecs_tasks_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-vpce-sg"
  }
}

# ---------------------------------------------
# ECR API Interface Endpoint
# ---------------------------------------------
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.main.id  # ✅ internal reference
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id  # ✅ internal reference
  security_group_ids  = [aws_security_group.vpce_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-ecr-api-vpce"
  }
}

# ---------------------------------------------
# ECR DKR Interface Endpoint
# ---------------------------------------------
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.main.id  # ✅ internal reference
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id  # ✅ internal reference
  security_group_ids  = [aws_security_group.vpce_sg.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-ecr-dkr-vpce"
  }
}

# ---------------------------------------------
# S3 Gateway Endpoint (Fixed - no cycle)
# ---------------------------------------------
data "aws_route_tables" "private" {
  vpc_id = aws_vpc.main.id  # ✅ internal reference
  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id  # ✅ internal reference
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"

  # ✅ Fixed: dynamic lookup instead of circular input
  route_table_ids = data.aws_route_tables.private.ids

  tags = {
    Name = "${var.project_name}-s3-gateway-vpce"
  }
}
