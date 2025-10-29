🧾 Example Terraform Output

After a successful deployment, you’ll see output values similar to the following:

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed. 
Apply complete! Resources: 0 added, 0 changed, 0 destroyed. 

Outputs: alb_dns_name = "nodejs-mongodb-aleem-alb-1469142445.us-east-1.elb.amazonaws.com" 

ecr_repository_url = "548813916475.dkr.ecr.us-east-1.amazonaws.com/nodejs-mongodb-aleem"

ecs_cluster_name = "nodejs-mongodb-aleem-cluster" 

ecs_service_name = "nodejs-mongodb-aleem-service" 

mongodb_secret_arn = <sensitive>

vpc_id = "vpc-0398c0cd45f096766"


You can then open your app using the ALB DNS name:

http://ecs-node-alb-1234567890.ap-south-1.elb.amazonaws.com/


Expected response:

{
  "message": "Hello from Node.js ECS App!",
  "environment": "dev"
}
