output "alb_dns_name" {
value = module.alb.alb_dns_name
}
output "ecs_cluster_name" {
value = module.ecs_cluster.cluster_name
}
output "ecs_service_name" {
value = module.ecs_service_service_name
description = "The ECS service name (root module creates service)"
}
