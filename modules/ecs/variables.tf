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
