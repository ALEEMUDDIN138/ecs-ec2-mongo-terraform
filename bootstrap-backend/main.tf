```hcl
terraform {
required_providers {
aws = { source = "hashicorp/aws" }
}
}
provider "aws" {
region = var.region
}


resource "aws_s3_bucket" "tfstate" {
bucket = var.bucket_name
acl = "private"


versioning {
enabled = true
}


tags = {
Name = "terraform-state-bucket"
}
}


resource "aws_dynamodb_table" "tf_locks" {
name = var.dynamodb_table
billing_mode = "PAY_PER_REQUEST"
hash_key = "LockID"


attribute {
name = "LockID"
type = "S"
}
}


output "bucket" {
value = aws_s3_bucket.tfstate.bucket
}
output "dynamodb_table" {
value = aws_dynamodb_table.tf_locks.name
}
