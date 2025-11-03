###############################################
# ============ LOAD BALANCER OUTPUT ===========
###############################################

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = try(module.alb.alb_dns_name, "ALB not created yet")
}

output "alb_target_group_arn" {
  description = "ALB Target Group ARN"
  value       = try(module.alb.target_group_arn, "Target group not created yet")
}

###############################################
# ============ ECS OUTPUTS ====================
###############################################

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = try(module.ecs.cluster_name, "Cluster not available")
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  # The ECS module may not expose 'service_name' directly, so we use try()
  # to avoid breaking Terraform validation
  value = try(module.ecs.service_name, try(module.ecs.ecs_service_name, "Service not available"))
}

###############################################
# ============ ECR OUTPUT =====================
###############################################

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = try(aws_ecr_repository.app.repository_url, "ECR repository not created yet")
}

###############################################
# ============ NETWORK OUTPUT =================
###############################################

output "vpc_id" {
  description = "ID of the VPC"
  value       = try(module.vpc.vpc_id, "VPC not available")
}
