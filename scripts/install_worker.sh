#!/bin/bash

set -e

set -u
: "$CLUSTER_NAME"
: "$MASTER_PRIVATE_IP"
: "$MASTER_PUBLIC_IP"
: "$LABEL"
: "$VALUE"
: "$AGENT_TOKEN"

### add registry as private registry in k3s configuration

cat << EOF >> /home/ec2-user/registries.yaml
mirrors:
  docker.io:
    endpoint:
      - "http://$MASTER_PRIVATE_IP:5000"
      - "https://registry-1.docker.io"
  $MASTER_PRIVATE_IP:5000:
    endpoint:
      - "http://$MASTER_PRIVATE_IP:5000"
EOF

### install k3s agent with private registry configuration and docker enabled.

export INSTALL_K3S_VERSION=v1.20.0+k3s2
export K3S_NODE_NAME=$(curl http://169.254.169.254/latest/meta-data/local-hostname)
export PROVIDER_ID=aws:///$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)/$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

export INSTALL_K3S_EXEC=" \
    --kubelet-arg cloud-provider=external \
    --node-label KubernetesCluster=$CLUSTER_NAME \
    --node-label $LABEL=$VALUE \
    --node-label groupRole=worker \
    --private-registry \"/home/ec2-user/registries.yaml\" \
    --kubelet-arg provider-id=$PROVIDER_ID "

curl -sfL https://get.k3s.io | K3S_URL=https://$MASTER_PUBLIC_IP:6443 K3S_TOKEN=$AGENT_TOKEN sh -
