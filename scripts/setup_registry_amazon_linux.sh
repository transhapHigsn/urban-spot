#!/bin/bash

set -e

### installing essentials

sudo yum update -y
sudo yum install git -y

### install docker for docker registry.

sudo amazon-linux-extras install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user

### allow insecure registries in docker daemon

INSTANCE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

cat << EOF >> /etc/docker/daemon.json
{"insecure-registries": ["$INSTANCE_IP:5000"]}
EOF

### restart docker service, so that above values are updated for docker daemon

sudo service docker restart

### run docker registry.

sudo docker run -d -p 5000:5000 --restart=always -e REGISTRY_STORAGE_DELETE_ENABLED=true --name registry registry:2
