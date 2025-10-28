output "mongodb_secret_arn" {
  description = "ARN of the MongoDB secret"
  value       = aws_secretsmanager_secret.mongodb.arn
}
