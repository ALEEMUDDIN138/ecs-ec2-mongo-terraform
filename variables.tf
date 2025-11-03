# ============ GLOBAL SETTINGS ============
variable "project_name" {
  description = "Project name for tagging and naming resources"
  type        = string
  default     = "terraform-ecs-nodejs-mongodb"
}

variable "region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

# ============ NETWORKING ============
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# ============ MONGODB ============
variable "mongodb_username" {
  description = "MongoDB username"
  type        = string
  default     = "admin"
}

variable "mongodb_password" {
  description = "MongoDB password"
  type        = string
  default     = "password123"
}

variable "mongodb_host" {
  description = "MongoDB host URL (Atlas or self-managed)"
  type        = string
  default     = "cluster0.mongodb.net"
}

variable "mongodb_database" {
  description = "MongoDB database name"
  type        = string
  default     = "nodeappdb"
}

# ✅ Added missing variable to fix Terraform error
variable "mongodb_ami_id" {
  description = "AMI ID to use for the MongoDB EC2 instance"
  type        = string
  default     = "ami-052064a798f08f0d3" # Replace with a valid MongoDB AMI ID
}

# ============ ECS CONFIG ============
variable "task_cpu" {
  description = "CPU units for ECS task"
  type        = string
  default     = "256"
}

variable "task_memory" {
  description = "Memory for ECS task (MB)"
  type        = string
  default     = "512"
}

variable "desired_count" {
  description = "Number of desired ECS tasks"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of ECS instances"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of ECS instances"
  type        = number
  default     = 3
}

variable "instance_type" {
  description = "EC2 instance type for ECS cluster"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key name for EC2 access"
  type        = string
  default     = "my-keypair"
}

# ============ BACKEND VARIABLES ============
variable "s3_bucket_name" {
  description = "Name of the S3 bucket to store Terraform state"
  type        = string
  default     = "Mongdb-nodjs"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for Terraform state locking"
  type        = string
  default     = "terraform-state-lock-aleem"
}

# ============ ECS OPTIMIZED AMI ============
variable "ecs_optimized_ami" {
  description = "ECS optimized AMI ID for EC2 instances"
  type        = string
  default     = "ami-052064a798f08f0d3" # Example for us-east-1 (Amazon Linux 2 ECS-Optimized)
}
