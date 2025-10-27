resource "aws_vpc" "this" {
cidr_block = var.cidr_block
tags = { Name = "ecs-vpc" }
}


resource "aws_internet_gateway" "gw" {
vpc_id = aws_vpc.this.id
}


resource "aws_subnet" "public" {
count = length(var.public_subnet_cidrs)
vpc_id = aws_vpc.this.id
cidr_block = var.public_subnet_cidrs[count.index]
map_public_ip_on_launch = true
availability_zone = data.aws_availability_zones.available.names[count.index]
tags = { Name = "public-${count.index+1}" }
}


resource "aws_subnet" "private" {
count = length(var.private_subnet_cidrs)
vpc_id = aws_vpc.this.id
cidr_block = var.private_subnet_cidrs[count.index]
availability_zone = data.aws_availability_zones.available.names[count.index]
tags = { Name = "private-${count.index+1}" }
}


resource "aws_route_table" "public" {
vpc_id = aws_vpc.this.id
}
resource "aws_route" "internet_access" {
route_table_id = aws_route_table.public.id
destination_cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.gw.id
}


resource "aws_route_table_association" "a" {
count = length(aws_subnet.public)
subnet_id = aws_subnet.public[count.index].id
route_table_id = aws_route_table.public.id
}


output "vpc_id" { value = aws_vpc.this.id }
output "public_subnets" { value = aws_subnet.public[*].id }
output "private_subnets" { value = aws_subnet.private[*].id }
