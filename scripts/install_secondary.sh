#!/bin/bash

set -e
set -u
: "$K3S_TOKEN"
: "$PRIMARY_IP"
: "$CLUSTER_NAME"
: "$REGISTRY_IP"

### installing essentials

sudo yum update -y
sudo yum install git -y

### add registry as private registry in k3s configuration

cat << EOF >> /home/ec2-user/registries.yaml
mirrors:
  docker.io:
    endpoint:
      - "http://$REGISTRY_IP:5000"
      - "https://registry-1.docker.io"
  $REGISTRY_IP:5000:
    endpoint:
      - "http://$REGISTRY_IP:5000"
EOF

### install k3s server

export INSTALL_K3S_VERSION=v1.20.0+k3s2
export K3S_NODE_NAME=$(curl http://169.254.169.254/latest/meta-data/local-hostname)
export PROVIDER_ID=aws:///$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)/$(curl -s http://169.254.169.254/latest/meta-data/instance-id)


export INSTALL_K3S_EXEC=" \
    --server https://$PRIMARY_IP:6443 \
    --flannel-backend=none \
    --cluster-cidr=192.168.0.0/16 \
    --disable-cloud-controller \
    --kubelet-arg cloud-provider=external \
    --write-kubeconfig-mode 644 \
    --disable traefik \
    --node-label KubernetesCluster=$CLUSTER_NAME \
    --node-label groupRole=master \
    --private-registry \"/home/ec2-user/registries.yaml\" \
    --tls-san $PRIMARY_IP \
    --kubelet-arg provider-id=$PROVIDER_ID "

curl -sfL https://get.k3s.io | sh -
