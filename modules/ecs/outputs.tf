output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "service_name" {
  description = "ECS Service Name (if available)"
  value       = try(local.service_name, "not_created")
}
