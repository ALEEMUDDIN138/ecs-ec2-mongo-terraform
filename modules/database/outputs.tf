output "mongodb_secret_arn" {
  description = "MongoDB secret ARN (exposed from submodule)"
  value       = try(module.mongodb.mongodb_secret_arn, null)
}
