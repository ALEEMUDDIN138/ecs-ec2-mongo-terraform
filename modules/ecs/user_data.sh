#!/bin/bash
#cloud-boothook
# Ensure ECS agent starts and joins the correct cluster

echo "ECS_CLUSTER=${cluster_name}" >> /etc/ecs/ecs.config
echo "ECS_ENABLE_CONTAINER_METADATA=true" >> /etc/ecs/ecs.config

# Optional but useful: enable ECS logs
mkdir -p /var/log/ecs
chown ec2-user:ec2-user /var/log/ecs

# Ensure the ECS agent starts
systemctl enable --now ecs
