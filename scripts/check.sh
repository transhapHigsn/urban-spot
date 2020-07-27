#!/bin/bash

### installing essentials
sudo yum update -y
sudo yum install git -y

### install docker for docker registry.
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user

### install custom metrics server dependency
# sudo apt install -y golang-cfssl (todo convert this into amazon linux 2 command)

### run docker registry.
sudo docker run -d -p 5000:5000 --restart=always -e REGISTRY_STORAGE_DELETE_ENABLED=true --name registry registry:2

### allow insecure registries in docker daemon
export INSTANCE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
export NODE_PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)

cat << EOF >> /etc/docker/daemon.json
{"insecure-registries": ["$INSTANCE_IP:5000"]}
EOF

### restart docker service, so that above values are updated for docker daemon
sudo service docker restart

### add registry as private registry in k3s configuration
cat << EOF >> /home/ec2-user/registries.yaml
mirrors:
  docker.io:
    endpoint:
      - "https://registry-1.docker.io"
  $INSTANCE_IP:5000:
    endpoint:
      - "http://$INSTANCE_IP:5000"
EOF

###
