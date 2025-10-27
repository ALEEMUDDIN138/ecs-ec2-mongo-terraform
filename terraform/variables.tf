variable "aws_region" {
default = "us-east-1"
}
variable "vpc_cidr" {
default = "10.0.0.0/16"
}
variable "public_subnet_cidrs" {
type = list(string)
default = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "private_subnet_cidrs" {
type = list(string)
default = ["10.0.101.0/24", "10.0.102.0/24"]
}
variable "instance_type" {
default = "t3.micro"
}
variable "ecs_desired_capacity" {
default = 2
}
variable "mongo_uri" {
description = "MongoDB connection string (from Atlas or self-managed)"
type = string
}
variable "image_tag" {
default = "v1"
}
