terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "aleem-terraform-state-us-east-1"
    key            = "ecs-nodejs-mongodb/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}

# ───────────────────────────────
# Terraform Backend Resources
# ───────────────────────────────
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.s3_bucket_name

  tags = {
    Name = "Terraform State Store"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = var.dynamodb_table_name
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform State Lock Table"
  }
}

# ───────────────────────────────
# ECR Repository
# ───────────────────────────────
resource "aws_ecr_repository" "app" {
  name = var.project_name

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = var.project_name
  }
}

# ───────────────────────────────
# VPC Module (Remote Source)
# ───────────────────────────────
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.project_name
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  public_subnets  = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Project = var.project_name
  }
}

# ───────────────────────────────
# ALB Module
# ───────────────────────────────
module "alb" {
  source = "./modules/alb"

  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnets
  project_name      = var.project_name
}

# ───────────────────────────────
# Database (MongoDB on EC2 or external)
# ───────────────────────────────
module "database" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"

  for_each = {
    mongodb = {
      name          = "${var.project_name}-mongodb"
      ami           = var.mongodb_ami_id
      instance_type = "t3.micro"
      subnet_id     = element(module.vpc.private_subnets, 0)
    }
  }

  name          = each.value.name
  ami           = each.value.ami
  instance_type = each.value.instance_type
  subnet_id     = each.value.subnet_id

  tags = {
    Name = "MongoDB"
  }
}

# ───────────────────────────────
# ECS Cluster and Service
# ───────────────────────────────
module "ecs" {
  source = "./modules/ecs"

  project_name          = var.project_name
  region                = var.region
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnets
  public_subnet_ids     = module.vpc.public_subnets
  ecs_security_group_id = module.vpc.default_security_group_id
  alb_security_group_id = module.alb.alb_security_group_id
  alb_target_group_arn  = module.alb.target_group_arn
  alb_listener          = module.alb.listener_arn
  desired_count         = var.desired_count
  task_cpu              = var.task_cpu
  task_memory           = var.task_memory
  min_size              = var.min_size
  max_size              = var.max_size
  instance_type         = var.instance_type
  key_name              = var.key_name
  app_image             = "${aws_ecr_repository.app.repository_url}:latest"
  ecs_optimized_ami     = var.ecs_optimized_ami

  container_environment = [
    {
      name  = "MONGODB_URI"
      value = "mongodb://${var.mongodb_username}:${var.mongodb_password}@${var.mongodb_host}/${var.mongodb_database}?retryWrites=true&w=majority"
    },
    {
      name  = "NODE_ENV"
      value = var.environment
    },
    {
      name  = "PORT"
      value = "3000"
    }
  ]
}
