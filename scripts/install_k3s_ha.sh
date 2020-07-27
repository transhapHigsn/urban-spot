#!/bin/bash

export INSTANCE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
export NODE_PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)

### install k3s server

export INSTALL_K3S_VERSION=v1.18.4+k3s1
export K3S_NODE_NAME=$(curl http://169.254.169.254/latest/meta-data/local-hostname)
export PROVIDER_ID=aws:///$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)/$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
export K3S_TOKEN=$CLUSTER_SECRET

export INSTALL_K3S_EXEC=" \
    --cluster-init \
    --flannel-backend=none \
    --cluster-cidr=192.168.0.0/16 \
    --disable-cloud-controller \
    --kubelet-arg cloud-provider=external \
    --write-kubeconfig-mode 644 \
    --disable traefik \
    --node-label KubernetesCluster=calico-check \
    --node-label groupRole=master \
    --private-registry \"/home/ec2-user/registries.yaml\" \
    --tls-san $NODE_PUBLIC_IP \
    --kubelet-arg provider-id=$PROVIDER_ID \
    --kubelet-arg allowed-unsafe-sysctls=kernel.msg*,net.core.somaxconn "

curl -sfL https://get.k3s.io | sh -

### run aws cloud controller manager manifest.
kubectl apply -f https://raw.githubusercontent.com/transhapHigsn/cloud-provider-aws/higsn-dev/manifests/rbac.yaml
kubectl apply -f https://raw.githubusercontent.com/transhapHigsn/cloud-provider-aws/higsn-dev/manifests/aws-cloud-controller-manager-daemonset.yaml

### run calico manifest here.
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

### kubectl apply -f https://gist.githubusercontent.com/transhapHigsn/d7c06f644fab01fba95e742e6b141f24/raw/fd84f29aeb9f35b8fccdb9e892008291ba6fdf51/calico.yaml

