#!/bin/bash
echo "ECS_CLUSTER=example-cluster" > /etc/ecs/ecs.config
start ecs
cd /home/ec2-user/
mkdir hedwig-services
sudo yum install aws-cli -y
/usr/bin/aws s3 cp s3://hedwigservice/  --region us-west-2 /home/ec2-user/hedwig-services/ --recursive
