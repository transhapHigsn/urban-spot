#!/bin/bash

set -e

set -u
: "$K3S_TOKEN"
: "$CLUSTER_NAME"

### add registry as private registry in k3s configuration

INSTANCE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

cat << EOF >> /home/ec2-user/registries.yaml
mirrors:
  docker.io:
    endpoint:
      - "http://$INSTANCE_IP:5000"
      - "https://registry-1.docker.io"
  $INSTANCE_IP:5000:
    endpoint:
      - "http://$INSTANCE_IP:5000"
EOF

### install k3s server

export NODE_PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
export INSTALL_K3S_VERSION=v1.20.0+k3s2
export K3S_NODE_NAME=$(curl http://169.254.169.254/latest/meta-data/local-hostname)
export PROVIDER_ID=aws:///$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)/$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

export INSTALL_K3S_EXEC=" \
    --cluster-init \
    --flannel-backend=none \
    --cluster-cidr=192.168.0.0/16
    --disable-cloud-controller \
    --kubelet-arg cloud-provider=external \
    --write-kubeconfig-mode 644 \
    --disable traefik \
    --node-label KubernetesCluster=$CLUSTER_NAME \
    --node-label groupRole=master \
    --private-registry \"/home/ec2-user/registries.yaml\" \
    --tls-san $NODE_PUBLIC_IP \
    --kubelet-arg provider-id=$PROVIDER_ID"

curl -sfL https://get.k3s.io | sh -

### copy node token for scp command
echo -n $(sudo cat /var/lib/rancher/k3s/server/node-token) > /home/ec2-user/node-token
