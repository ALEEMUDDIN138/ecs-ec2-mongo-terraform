variable "project_name" {
  description = "Project name"
  type        = string
}

variable "mongodb_username" {
  description = "MongoDB username"
  type        = string
}

variable "mongodb_password" {
  description = "MongoDB password"
  type        = string
  sensitive   = true
}

variable "mongodb_host" {
  description = "MongoDB host (Atlas cluster URI)"
  type        = string
}

variable "mongodb_database" {
  description = "MongoDB database name"
  type        = string
}
