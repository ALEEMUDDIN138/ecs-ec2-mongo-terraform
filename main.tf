terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    # This will be filled in during terraform init
    bucket         = "my-terraform-state-bucket"
    key            = "ecs-nodejs-mongodb/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}

# S3 Bucket for Terraform State
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

# DynamoDB for State Locking
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

# ECR Repository
resource "aws_ecr_repository" "app" {
  name = var.project_name

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = var.project_name
  }
}

# Modules
module "networking" {
  source = "./modules/networking"

  project_name          = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "alb" {
  source = "./modules/alb"

  project_name         = var.project_name
  vpc_id              = module.networking.vpc_id
  public_subnet_ids   = module.networking.public_subnet_ids
  alb_security_group_id = module.networking.alb_security_group_id
}

module "database" {
  source = "./modules/database"

  project_name     = var.project_name
  mongodb_username = var.mongodb_username
  mongodb_password = var.mongodb_password
  mongodb_host     = var.mongodb_host
  mongodb_database = var.mongodb_database
}

module "ecs" {
  source = "./modules/ecs"

  project_name        = var.project_name
  region             = var.region
  app_image          = "${aws_ecr_repository.app.repository_url}:latest"
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  ecs_security_group_id = module.networking.ecs_security_group_id
  alb_target_group_arn = module.alb.target_group_arn
  alb_listener       = module.alb.listener

  task_cpu    = var.task_cpu
  task_memory = var.task_memory
  desired_count = var.desired_count
  min_size    = var.min_size
  max_size    = var.max_size
  instance_type = var.instance_type
  key_name    = var.key_name

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

  ecs_optimized_ami = data.aws_ami.ecs_optimized.id
}

data "aws_ami" "ecs_optimized" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
