provider "aws" {
  region  = "us-east-2"
  profile = "default"
}


resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.deployer-public-key
}

data "aws_iam_instance_profile" "master_profile" {
  name = "k3s-master-role-profile"
}


resource "aws_instance" "master-node-12" {
  ami                  = var.ami_id
  instance_type        = var.master_instance_type
  subnet_id            = var.public_subnets[0]
  key_name             = aws_key_pair.deployer.key_name
  iam_instance_profile = data.aws_iam_instance_profile.master_profile.id
  # vpc_security_group_ids = [module.bastion.private_instances_security_group]

  user_data = templatefile("data/main-server-init.tmpl", { cluster_name = var.cluster_name })

  tags = {
    Terraform                                   = "true"
    Environment                                 = "dev"
    Name                                        = "master-1"
    "kubernetes.io/role"                        = "master"
    "KubernetesCluster"                         = var.cluster_name
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

}

resource "null_resource" "echo_master_ip" {
  provisioner "local-exec" {
    command = "sleep 120s && echo ${aws_instance.master-node-12.public_ip}"
  }
}

resource "aws_instance" "master-node-11" {
  ami                  = var.ami_id
  instance_type        = var.master_instance_type
  subnet_id            = var.public_subnets[1]
  key_name             = aws_key_pair.deployer.key_name
  iam_instance_profile = data.aws_iam_instance_profile.master_profile.id
  # vpc_security_group_ids = [module.bastion.private_instances_security_group]

  user_data = templatefile("data/server-init.tmpl", {
    cluster_name   = var.cluster_name,
    DOCKER_IP      = aws_instance.master-node-12.private_ip,
    MAIN_PUBLIC_IP = aws_instance.master-node-12.public_ip
  })

  tags = {
    Terraform                                   = "true"
    Environment                                 = "dev"
    Name                                        = "master-2"
    "kubernetes.io/role"                        = "master"
    "KubernetesCluster"                         = var.cluster_name
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  depends_on = [
    aws_instance.master-node-12.id,
  ]

}

resource "aws_instance" "master-node-10" {
  ami                  = "ami-026dea5602e368e96"
  instance_type        = "t3a.large"
  subnet_id            = var.public_subnets[2]
  key_name             = aws_key_pair.deployer.key_name
  iam_instance_profile = data.aws_iam_instance_profile.master_profile.id
  # vpc_security_group_ids = [module.bastion.private_instances_security_group]

  user_data = templatefile("data/server-init.tmpl", {
    cluster_name   = var.cluster_name,
    DOCKER_IP      = aws_instance.master-node-12.private_ip,
    MAIN_PUBLIC_IP = aws_instance.master-node-12.public_ip
  })

  tags = {
    Terraform                                   = "true"
    Environment                                 = "dev"
    Name                                        = "master-3"
    "kubernetes.io/role"                        = "master"
    "KubernetesCluster"                         = var.cluster_name
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  depends_on = [
    aws_instance.master-node-12.id,
  ]

}

# copying information from master node.

resource "null_resource" "copy-kubeconfig" {
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${aws_instance.master-node-12.public_ip}:/etc/rancher/k3s/k3s.yaml ./k3s-kubeconfig.yaml"
  }
  depends_on = [null_resource.echo_master_ip]
}

resource "null_resource" "copy-nodetoken" {
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${aws_instance.master-node-12.public_ip}:/home/ubuntu/node-token ./node-token"
  }
  depends_on = [null_resource.echo_master_ip]
}