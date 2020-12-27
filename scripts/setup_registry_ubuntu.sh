#!/bin/bash

set -e

sudo apt-get -y update
sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get -y update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io

# update this according to cloud provider, this is for upcloud.
# export PRIV_IP=$(curl http://169.254.169.254/metadata/v1/network/interfaces/2/ip_addresses/1/address)

# for aws
PRIV_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

cat << EOF >> /etc/docker/daemon.json
{"insecure-registries": ["$PRIV_IP:5000"]}
EOF

sudo service docker restart

sudo docker run -d -p 5000:5000 --restart=always -e REGISTRY_STORAGE_DELETE_ENABLED=true --name registry registry:2
