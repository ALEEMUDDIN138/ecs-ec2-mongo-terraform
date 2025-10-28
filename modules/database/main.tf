# Using MongoDB Atlas (you'll need to set up Atlas separately)
# This module provides outputs for MongoDB connection details

resource "aws_secretsmanager_secret" "mongodb" {
  name = "${var.project_name}-mongodb-credentials"
  
  tags = {
    Name = "${var.project_name}-mongodb-secret"
  }
}

resource "aws_secretsmanager_secret_version" "mongodb" {
  secret_id = aws_secretsmanager_secret.mongodb.id
  secret_string = jsonencode({
    username = var.mongodb_username
    password = var.mongodb_password
    host     = var.mongodb_host
    database = var.mongodb_database
  })
}
