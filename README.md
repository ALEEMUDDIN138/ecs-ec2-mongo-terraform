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

---

## ⚙️ 2. Configure Terraform Backend

1. Create an S3 bucket and DynamoDB table for Terraform state:

   ```bash
   aws s3api create-bucket --bucket my-terraform-state-bucket --region ap-south-1
   aws dynamodb create-table \
     --table-name terraform-locks \
     --attribute-definitions AttributeName=LockID,AttributeType=S \
     --key-schema AttributeName=LockID,KeyType=HASH \
     --billing-mode PAY_PER_REQUEST
   ```

2. Update your backend config in `terraform/backend/main.tf`:

   ```hcl
   terraform {
     backend "s3" {
       bucket         = "my-terraform-state-bucket"
       key            = "ecs-nodejs/terraform.tfstate"
       region         = "ap-south-1"
       dynamodb_table = "terraform-locks"
       encrypt        = true
     }
   }
   ```

3. Initialize Terraform:

   ```bash
   cd terraform
   terraform init
   ```

---

## 🐳 3. Build and Push Docker Image to ECR

1. Create an ECR repository:

   ```bash
   aws ecr create-repository --repository-name ecs-node-mongo-app
   ```

2. Authenticate Docker with ECR:

   ```bash
   aws ecr get-login-password --region ap-south-1 | \
   docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.ap-south-1.amazonaws.com
   ```

3. Build and push the image:

   ```bash
   docker build -t ecs-node-mongo-app:latest ./app
   docker tag ecs-node-mongo-app:latest <aws_account_id>.dkr.ecr.ap-south-1.amazonaws.com/ecs-node-mongo-app:latest
   docker push <aws_account_id>.dkr.ecr.ap-south-1.amazonaws.com/ecs-node-mongo-app:latest
   ```

---

## ☁️ 4. Deploy Infrastructure with Terraform

Run the following commands from the `terraform/` directory:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

**Terraform Outputs:**

* `alb_dns_name` → Application Load Balancer URL
* `ecs_cluster_name` → ECS Cluster name
* `service_name` → ECS Service name

---

## 🔐 5. Environment Variables

In your ECS Task Definition, Terraform passes the following environment variables to the container:

| Variable      | Description                                       |
| ------------- | ------------------------------------------------- |
| `MONGO_URI`   | MongoDB connection string (Atlas or self-managed) |
| `PORT`        | Application port (default 3000)                   |
| `ENVIRONMENT` | Deployment environment name (e.g., dev, prod)     |

Example snippet from ECS task definition:

```hcl
environment = [
  {
    name  = "MONGO_URI"
    value = "mongodb+srv://<username>:<password>@cluster.mongodb.net/mydb"
  },
  {
    name  = "ENVIRONMENT"
    value = var.environment
  }
]
```

---

## 🌐 6. Access the Application

After successful deployment, Terraform outputs the ALB DNS name:

```bash
Outputs:
alb_dns_name = "ecs-node-app-alb-123456789.ap-south-1.elb.amazonaws.com"
```

Access your application in a browser:

```
http://ecs-node-app-alb-123456789.ap-south-1.elb.amazonaws.com/
```

Expected output:

```json
{
  "message": "Hello from Node.js ECS App!",
  "environment": "dev"
}
```

---

## 🧹 7. Cleanup

To remove all resources and avoid AWS charges:

```bash
terraform destroy -auto-approve
```

Also delete your ECR images if no longer needed:

```bash
aws ecr delete-repository --repository-name ecs-node-mongo-app --force
```

---

### 📘 References

* [AWS ECS Developer Guide](https://docs.aws.amazon.com/ecs/latest/developerguide/)
* [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
* [Docker + ECR Docs](https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html)
