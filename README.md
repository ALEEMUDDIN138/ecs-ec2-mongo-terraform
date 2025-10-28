# 🚀 Node.js + MongoDB on AWS ECS (EC2) — Terraform Deployment

This project demonstrates deploying a simple **Node.js REST API** connected to **MongoDB**, containerized with **Docker**, and deployed on **AWS ECS (EC2 launch type)** using **Terraform** with an S3 backend and DynamoDB for state locking.

---

## 📁 1. Project File Tree

```
Ecs-ec2-mongo-terraform-repo/
terraform-ecs-nodejs-mongodb/
├── app/
│   ├── Dockerfile
│   ├── package.json
│   ├── server.js
│   └── .dockerignore
├── modules/
│   ├── networking/
│   ├── ecs/
│   ├── database/
│   └── alb/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars.example
├── README.md
└── ecs-comparison.md
```

# Node.js with MongoDB on AWS ECS

This project deploys a Node.js application with MongoDB backend on AWS ECS using Terraform.

## Architecture

- **Frontend**: Node.js application containerized with Docker
- **Orchestration**: AWS ECS with EC2 launch type
- **Load Balancer**: Application Load Balancer (ALB)
- **Database**: MongoDB (Atlas or self-managed)
- **Infrastructure as Code**: Terraform with S3 backend and DynamoDB state locking

## Prerequisites

1. AWS CLI configured with appropriate permissions
2. Terraform installed (>= 1.0)
3. Docker installed
4. MongoDB instance (Atlas or self-managed)

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd terraform-ecs-nodejs-mongodb

2. Set up MongoDB

Option A: MongoDB Atlas (Recommended)
Create a MongoDB Atlas account
Create a cluster
Create a database user
Get the connection string
Option B: Self-managed MongoDB
Deploy MongoDB on EC2 or use DocumentDB
developer.hashicorp.comdeveloper.hashicorp.com
Terraform | HashiCorp Developer
Explore Terraform product documentation, tutorials, and examples. (124 kB)
https://variables.tf/

3. Build and Push Docker Image
bash
# Navigate to app directory
cd app

# Build the Docker image
docker build -t nodejs-mongodb-app .

# Get ECR login token
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

# Tag the image
docker tag nodejs-mongodb-app:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/nodejs-mongodb-app:latest

# Push to ECR
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/nodejs-mongodb-app:latest

4. Terraform Deployment
Initialize Terraform
bash
# Initialize with S3 backend
terraform init -backend-config="bucket=my-terraform-state-bucket" \
               -backend-config="key=ecs-nodejs-mongodb/terraform.tfstate" \
               -backend-config="region=us-east-1" \
               -backend-config="dynamodb_table=terraform-state-lock"

Configure Variables
bash
# Copy example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
vim terraform.tfvars

Plan and Apply
bash
# Plan the deployment
terraform plan

# Apply the configuration
terraform apply

5. Access the Application
After deployment, get the ALB DNS name:
bash
terraform output alb_dns_name

Access the application:
Homepage: http://<alb-dns-name>
Health check: http://<alb-dns-name>/health
API endpoints: http://<alb-dns-name>/items
Application Endpoints
GET / - Application info
GET /health - Health check
GET /items - Get all items
POST /items - Create new item
Environment Variables
MONGODB_URI - MongoDB connection string
NODE_ENV - Environment (production/development)
PORT - Application port (default: 3000)

Clean Up
bash
terraform destroy

Troubleshooting
Check ECS service logs in CloudWatch
Verify security group rules
Check ALB target group health
Verify MongoDB connectivity from ECS tasks
