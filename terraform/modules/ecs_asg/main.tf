# IAM role for EC2 instances to join ECS
resource "aws_iam_role" "ecs_instance_role" {
name = "ecsInstanceRole-${random_id.suffix.hex}"
assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
}
resource "aws_iam_role_policy_attachment" "ecs_instance_policy" {
role = aws_iam_role.ecs_instance_role.name
policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
resource "aws_iam_role_policy_attachment" "ssm" {
role = aws_iam_role.ecs_instance_role.name
policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_launch_template" "ecs" {
name_prefix = "ecs-launch-"
image_id = data.aws_ami.ecs_ami.id
instance_type = var.instance_type
iam_instance_profile {
name = aws_iam_instance_profile.ecs_profile.name
}
user_data = base64encode(templatefile("${path.module}/user-data.tpl", { cluster_name = var.cluster_name }))
tag_specifications {
resource_type = "instance"
tags = { Name = "ecs-instance" }
}
}


resource "aws_autoscaling_group" "ecs_asg" {
name_prefix = "ecs-asg-"
max_size = var.max_size
min_size = var.min_size
desired_capacity = var.desired_capacity
launch_template {
id = aws_launch_template.ecs.id
version = "$Latest"
}
vpc_zone_identifier = var.public_subnet_ids
tag {
key = "Name"
value = "ecs-asg"
propagate_at_launch = true
}
}


resource "aws_iam_instance_profile" "ecs_profile" {
name = "ecs-instance-profile-${random_id.suffix.hex}"
