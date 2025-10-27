🧾 Example Terraform Output

After a successful deployment, you’ll see output values similar to the following:

Outputs:

alb_dns_name = "ecs-node-alb-1234567890.ap-south-1.elb.amazonaws.com"
ecs_cluster_name = "ecs-node-cluster"
ecs_service_name = "ecs-node-service"
ecr_repository_url = "123456789012.dkr.ecr.ap-south-1.amazonaws.com/ecs-node-mongo-app"
asg_name = "ecs-ec2-asg-nodeapp"
ecs_service_sg_id = "sg-0a1b2c3d4e5f67890"
vpc_id = "vpc-0123abcd4567efgh8"
subnet_ids = [
  "subnet-01a2b3c4d5e6f7a8b",
  "subnet-02a2b3c4d5e6f7a8b"
]


You can then open your app using the ALB DNS name:

http://ecs-node-alb-1234567890.ap-south-1.elb.amazonaws.com/


Expected response:

{
  "message": "Hello from Node.js ECS App!",
  "environment": "dev"
}
