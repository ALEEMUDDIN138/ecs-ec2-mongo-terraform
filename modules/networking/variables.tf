variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where ECS will run"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for ECS service"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ECS service"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ALB security group ID"
  type        = string
}

variable "ecs_security_group_id" {
  description = "ECS security group ID"
  type        = string
}

variable "alb_target_group_arn" {
  description = "ALB target group ARN"
  type        = string
}

variable "alb_listener" {
  description = "ALB listener ARN"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "app_image" {
  description = "ECR image URL for ECS task"
  type        = string
}

variable "task_cpu" {
  description = "CPU for ECS task"
  type        = number
}

variable "task_memory" {
  description = "Memory for ECS task"
  type        = number
}

variable "desired_count" {
  description = "Desired ECS service count"
  type        = number
}

variable "min_size" {
  description = "Minimum ECS autoscaling group size"
  type        = number
}

variable "max_size" {
  description = "Maximum ECS autoscaling group size"
  type        = number
}

variable "instance_type" {
  description = "Instance type for ECS cluster"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "container_environment" {
  description = "Environment variables for container"
  type        = list(object({
    name  = string
    value = string
  }))
}

variable "ecs_optimized_ami" {
  description = "AMI ID for ECS-optimized instances"
  type        = string
}

[ec2-user@ip-172-31-23-81 ecs]$ cd ..
[ec2-user@ip-172-31-23-81 modules]$ cd networking/
[ec2-user@ip-172-31-23-81 networking]$ cat variable.tf
# ───────────────────────────────────────────────
# Existing variables (already in your file)
# ───────────────────────────────────────────────
variable "project_name" {}
variable "vpc_cidr" {}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

# ───────────────────────────────────────────────
# New variables for VPC Endpoints
# ───────────────────────────────────────────────

# The VPC ID where endpoints will be created
variable "vpc_id" {
  description = "VPC ID for creating VPC Endpoints"
  type        = string
}

# The list of private subnet IDs (endpoints will attach here)
variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECR interface endpoints"
  type        = list(string)
}

# The route table IDs used by private subnets (for the S3 Gateway Endpoint)
variable "private_route_table_ids" {
  description = "Route table IDs for private subnets"
  type        = list(string)
}

# The ECS tasks' security group ID (used to allow HTTPS to endpoints)
variable "ecs_tasks_sg_id" {
  description = "Security group ID of ECS tasks that need ECR access"
  type        = string
}

variable "create_vpc_endpoints" {
  type    = bool
  default = false
}
