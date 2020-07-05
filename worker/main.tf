provider "aws" {
  region  = "us-east-2"
  profile = "default"
}

data "aws_instance" "master" {

  filter {
    name   = "image-id"
    values = [var.ami_id]
  }

  filter {
    name   = "tag:Name"
    values = ["master-1"]
  }

  filter {
    name   = "tag:Terraform"
    values = ["true"]
  }

  filter {
    name   = "tag:KubernetesCluster"
    values = [var.cluster_name]
  }
}

resource "aws_instance" "worker-node-12" {
  ami                  = var.ami_id
  instance_type        = var.worker_instance_type
  subnet_id            = var.public_subnets[0]
  key_name             = data.aws_instance.master.key_name
  iam_instance_profile = data.aws_instance.master.iam_instance_profile

  user_data = templatefile("data/agent-init.tmpl", {
    master_ip       = data.aws_instance.master.public_ip,
    master_local_ip = data.aws_instance.master.private_ip,
    node_token      = var.k3s_token,
    cluster_name    = var.cluster_name,
    label           = "main-stream",
    value           = "false",
    instance_env    = "dev",
    purpose         = "dev"
  })

  tags = {
    Terraform            = "true"
    Environment          = "dev"
    Name                 = "worker-1"
    "kubernetes.io/role" = "worker"
    "KubernetesCluster"  = var.cluster_name
  }

}

resource "aws_instance" "worker-node-11" {
  ami                  = var.ami_id
  instance_type        = var.worker_instance_type
  subnet_id            = var.public_subnets[1]
  key_name             = data.aws_instance.master.key_name
  iam_instance_profile = data.aws_instance.master.iam_instance_profile

  user_data = templatefile("data/agent-init.tmpl", {
    master_ip       = data.aws_instance.master.public_ip,
    master_local_ip = data.aws_instance.master.private_ip,
    node_token      = var.k3s_token,
    cluster_name    = var.cluster_name,
    label           = "main-stream",
    value           = "false",
    instance_env    = "dev",
    purpose         = "dev"
  })

  tags = {
    Terraform            = "true"
    Environment          = "dev"
    Name                 = "worker-2"
    "kubernetes.io/role" = "worker"
    "KubernetesCluster"  = var.cluster_name
  }

}
