#!/bin/bash

set -e

# update this according to cloud provider. this is for upcloud.
# PRIV_IP=$(curl http://169.254.169.254/metadata/v1/network/interfaces/2/ip_addresses/1/address)

# for aws
PRIV_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)


### download images.txt files in current directory.

BRANCH_NAME="etcd_ha"
url="https://raw.githubusercontent.com/transhapHigsn/urban-spot/$BRANCH_NAME/images.txt"
wget $url

while read LINE
do
    echo "$LINE"
    
    org_name=$(echo "$LINE" | cut -d "/" -f 2)
    name=$(echo "$LINE" | cut -d "/" -f 3)
    final_image_name=$(echo $org_name/$name)
    echo "$final_image_name"

    local_image_name=$(echo $PRIV_IP:5000/$org_name/$name)

    sudo docker pull $LINE
    sudo docker tag $final_image_name $local_image_name
    sudo docker push $local_image_name

done < $(pwd)/images.txt

echo "Yeah! All required images are pulled into private registry"
