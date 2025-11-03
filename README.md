# 🚀 Node.js + MongoDB on AWS ECS (EC2) — Terraform Deployment

This project demonstrates deploying a simple **Node.js REST API** connected to **MongoDB**, containerized with **Docker**, and deployed on **AWS ECS (EC2 launch type)** using **Terraform** with an S3 backend and DynamoDB for state locking.

---

## 📁 1. Project File Tree

```
Ecs-ec2-mongo-terraform-repo/
terraform-ecs-nodejs-mongodb/
├── app/
│   ├── app.js
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
├── Dockerfile
├── terraform.tfvars.example
├── README.md
|__ Terraform output.md
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

### 2. Set up MongoDB

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

### 3. Build and Push Docker Image
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

### 4. Terraform Deployment

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

### 5. Access the Application

After deployment, get the ALB DNS name:
bash
terraform output alb_dns_name

## Access the application:
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

## Clean Up
bash
terraform destroy

## Troubleshooting
Check ECS service logs in CloudWatch
Verify security group rules
Check ALB target group health
Verify MongoDB connectivity from ECS tasks

## Step-by-Step Execution

Step 1: Prerequisites Setup
bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install Terraform
wget https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip
unzip terraform_1.5.7_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Configure AWS CLI
aws configure

Step 2: Prepare Application
bash
# Create project structure
mkdir -p terraform-ecs-nodejs-mongodb/{app,modules/{networking,ecs,database,alb}}
cd terraform-ecs-nodejs-mongodb

# Create all the files as shown above
# ... create Dockerfile, server.js, package.json, etc.

Step 3: Build and Push Docker Image
bash
cd app

# Build the application
npm install

# Build Docker image
docker build -t nodejs-mongodb-app .

# Create ECR repository (if not exists)
aws ecr create-repository --repository-name nodejs-mongodb-app --region us-east-1

# Get login token and login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com

# Tag and push image
docker tag nodejs-mongodb-app:latest $(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com/nodejs-mongodb-app:latest
docker push $(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com/nodejs-mongodb-app:latest

cd ..

Step 4: Terraform Deployment
bash
# Initialize Terraform with S3 backend
terraform init -backend-config="bucket=my-terraform-state-bucket" \
               -backend-config="key=ecs-nodejs-mongodb/terraform.tfstate" \
               -backend-config="region=us-east-1" \
               -backend-config="dynamodb_table=terraform-state-lock"

# Create terraform.tfvars
cat > terraform.tfvars << EOF
region = "us-east-1"
project_name = "nodejs-mongodb-app"
environment = "production"

s3_bucket_name = "my-terraform-state-bucket-$(aws sts get-caller-identity --query Account --output text)"
dynamodb_table_name = "terraform-state-lock"

mongodb_username = "admin"
mongodb_password = "your-secure-password"
mongodb_host = "your-cluster.mongodb.net"
mongodb_database = "mydb"

task_cpu = 256
task_memory = 512
desired_count = 2
min_size = 1
max_size = 3
instance_type = "t3.small"
EOF

# Plan and apply
terraform plan
terraform apply -auto-approve

Step 5: Verify Deployment
bash
# Get ALB endpoint
ALB_DNS=$(terraform output -raw alb_dns_name)
echo "Application URL: http://$ALB_DNS"Step 6: Monitoring and Logs
bash

# Test the application
curl http://$ALB_DNS
curl http://$ALB_DNS/health

# Test API endpoints
curl -X POST http://$ALB_DNS/items \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Item","description":"This is a test"}'

curl http://$ALB_DNS/items

Step 6: Monitoring and Logs
bash
# Get ECS cluster name
CLUSTER_NAME=$(terraform output -raw ecs_cluster_name)

# Get running tasks
aws ecs list-tasks --cluster $CLUSTER_NAME

# Get task details
TASK_ARN=$(aws ecs list-tasks --cluster $CLUSTER_NAME --query 'taskArns[0]' --output text)
aws ecs describe-tasks --cluster $CLUSTER_NAME --tasks $TASK_ARN

# Check CloudWatch logs
LOG_GROUP="/ecs/nodejs-mongodb-app"
aws logs describe-log-streams --log-group-name $LOG_GROUP --order-by LastEventTime --descending

## This complete solution provides:
Terraform with S3 backend and DynamoDB locking
Modular Terraform code
Containerized Node.js app with MongoDB
ECS with EC2 Auto Scaling Group
Environment variables for configuration
Application Load Balancer
Complete documentation and comparison
All required outputs
The application is now deployed and accessible via the ALB DNS name!
