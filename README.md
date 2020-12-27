# Urban Spot: K3S HA Setup using Embedded Etcd and Calico CNI on AWS

This setup tries to implement Embedded etcd experimental high availability setup of k3s. Apart from that, setup uses Calico CNI instead of default Flannel CNI.

Note: Setup is done exclusively for Amazon Linux 2 AMI.

## Features

- Amazon Linux 2
- AWS Cloud controller manager
- Calico CNI
- Private docker registry for cluster
- Insecure registry access within cluster
- Support for Cluster auto-scaler

## RoadMap

- Single command to provision everything.
- Stricter security group rules.
- Use kube2iam/kiam for IAM roles.
- Add Loadbalancer support.
- and many others tbd.

## Usage

The terraform scripts are divided into different modules, all are standalone. You can either start from scratch or pick any based on your requirements. As of now, the project contains following modules:

- VPC
- IAM
- Master
- Worker

All of the modules are fully customizable. Terraform scripts will run even if you want to go with default. For first time, run modules by executing following commands from the root of the module:

```bash
terraform init
terraform apply -auto-approve
```

Except for Master:

```bash
terraform init
export PUBLIC_SSH_KEY=$(cat /path/to/public/ssh/key)
terraform apply -var="deployer-public-key=$PUBLIC_SSH_KEY"
```

Note: Worker modules uses ssh key used for master module, but you don't have to define that explicitly.

On following runs:

```bash
terraform apply -auto-approve
```

will work. To destroy provisioned resources in a module, just run

```bash
terraform destroy -auto-approve
```

**Disclaimer: This is just for testing and development purposes, do not use this for production environment.**
