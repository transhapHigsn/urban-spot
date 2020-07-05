provider "aws" {
  region  = "us-east-2"
  profile = "default"
}

resource "aws_instance" "worker-node-12" {
  ami                  = var.ami_id
  instance_type        = var.worker_instance_type
  subnet_id            = var.public_subnets[0]
  key_name             = aws_key_pair.deployer.key_name
  iam_instance_profile = aws_iam_instance_profile.k3s-master-role-profile.id

  user_data = templatefile("data/agent-init.tmpl", {
    master_ip       = aws_instance.master-node-12.public_ip,
    master_local_ip = aws_instance.master-node-12.private_ip,
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
  key_name             = aws_key_pair.deployer.key_name
  iam_instance_profile = aws_iam_instance_profile.k3s-master-role-profile.id

  user_data = templatefile("data/agent-init.tmpl", {
    master_ip       = aws_instance.master-node-12.public_ip,
    master_local_ip = aws_instance.master-node-12.private_ip,
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
