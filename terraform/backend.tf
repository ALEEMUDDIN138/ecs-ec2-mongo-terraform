terraform {
backend "s3" {
bucket = "<PUT_BUCKET_NAME_HERE>" # replace with bootstrap output
key = "ecs-ec2-mongo/terraform.tfstate"
region = "us-east-1"
dynamodb_table = "<PUT_DYNAMODB_TABLE_HERE>"
encrypt = true
}
}
