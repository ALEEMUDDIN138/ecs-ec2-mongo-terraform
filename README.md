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
This creates an S3 bucket and DynamoDB table for locking. Note the bucket name and table name.


2) Configure terraform backend
Edit terraform/backend.tf and set bucket and dynamodb_table to values created above (or set via environment variables/terraform.tfvars).

# 1. Create ECR repo (Terraform will create one, but you can create manually or run terraform apply first)
# 2. Authenticate Docker to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
Alternatively run terraform apply first which creates the ECR repo and then run the push steps using the repo URI output from Terraform.

3) Build and push Docker image to ECR
# Build and tag (example tag: v1)
docker build -t node-mongo-sample:latest ./app
TAG=v1
REPO_URI=$(aws ecr describe-repositories --repository-names node-mongo-sample --region us-east-1 --query 'repositories[0].repositoryUri' --output text)
docker tag node-mongo-sample:latest ${REPO_URI}:${TAG}
docker push ${REPO_URI}:${TAG}


4) Deploy infra with Terraform
cd terraform
# configure backend.tf variables or use -var-file
terraform init
terraform plan -out=tfplan
terraform apply tfplan


5) Environment variables
Set these variables in the ECS Task definition via Terraform (example in vars):

MONGO_URI — MongoDB connection string (e.g., from Atlas or EC2-hosted Mongo)

NODE_ENV — environment name production

6) Access the app

Terraform outputs the ALB DNS name. Example:
ALB DNS: ${alb_dns_name}
Open in browser.

7) Cleanup
terraform destroy -auto-approve
# and optionally destroy bootstrap resources
cd ../bootstrap-backend
terraform destroy -auto-approve
