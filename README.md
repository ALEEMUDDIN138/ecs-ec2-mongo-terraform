# ECS EC2 Node.js + MongoDB (Terraform)


This repo deploys a sample Node.js application to AWS ECS (EC2) with MongoDB backend and Terraform state in S3 with DynamoDB locking.


## Highlights
- Terraform remote state in S3 with DynamoDB locking
- Modular Terraform (vpc, ecr, ecs_cluster, ecs_asg, alb)
- Node.js sample app that reads MongoDB connection string from env
- Dockerfile to build container and push to ECR
- ALB exposes app on port 80


## Pre-requisites
- AWS CLI configured with credentials
- Terraform v1.3+ (compatible)
- Docker
- jq (helpful)


## 1) Bootstrap Terraform backend (run locally once)


```bash
cd bootstrap-backend
terraform init
terraform apply -var="bucket_name=your-tf-state-bucket-$(date +%s)" -var="dynamodb_table=tf-locks-$(date +%s)" -auto-approve
