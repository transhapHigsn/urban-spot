provider "aws" {
  region  = var.region
  profile = var.profile
}


resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.deployer-public-key
}

data "aws_iam_instance_profile" "master_profile" {
  name = "k3s-master-role-profile"
}

data "aws_subnet" "public_subnet_1" {
  cidr_block = var.public_subnet_cidr_blocks[0]
}

data "aws_subnet" "public_subnet_2" {
  cidr_block = var.public_subnet_cidr_blocks[1]
}

data "aws_subnet" "public_subnet_3" {
  cidr_block = var.public_subnet_cidr_blocks[2]
}


resource "aws_instance" "master-node-12" {
  ami                  = var.ami_id
  instance_type        = var.master_instance_type
  subnet_id            = data.aws_subnet.public_subnet_1.id
  key_name             = aws_key_pair.deployer.key_name
  iam_instance_profile = data.aws_iam_instance_profile.master_profile.name
  # vpc_security_group_ids = [module.bastion.private_instances_security_group]

  user_data = templatefile("data/main-server-init.tmpl", {
    cluster_name  = var.cluster_name,
    cluster_token = var.cluster_server_token
  })

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
    command = "sleep 210s && echo ${aws_instance.master-node-12.public_ip}"
  }
}

resource "aws_instance" "master-node-11" {
  ami                  = var.ami_id
  instance_type        = var.master_instance_type
  subnet_id            = data.aws_subnet.public_subnet_2.id
  key_name             = aws_key_pair.deployer.key_name
  iam_instance_profile = data.aws_iam_instance_profile.master_profile.name
  # vpc_security_group_ids = [module.bastion.private_instances_security_group]

  user_data = templatefile("data/server-init.tmpl", {
    cluster_name      = var.cluster_name,
    registry_ip       = aws_instance.master-node-12.private_ip,
    cluster_public_ip = aws_instance.master-node-12.public_ip,
    cluster_token     = var.cluster_server_token
  })

  tags = {
    Terraform                                   = "true"
    Environment                                 = "dev"
    Name                                        = "master-2"
    "kubernetes.io/role"                        = "master"
    "KubernetesCluster"                         = var.cluster_name
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  depends_on = [null_resource.echo_master_ip]

}

resource "aws_instance" "master-node-10" {
  ami                  = var.ami_id
  instance_type        = var.master_instance_type
  subnet_id            = data.aws_subnet.public_subnet_3.id
  key_name             = aws_key_pair.deployer.key_name
  iam_instance_profile = data.aws_iam_instance_profile.master_profile.name
  # vpc_security_group_ids = [module.bastion.private_instances_security_group]

  user_data = templatefile("data/server-init.tmpl", {
    cluster_name      = var.cluster_name,
    registry_ip       = aws_instance.master-node-12.private_ip,
    cluster_public_ip = aws_instance.master-node-12.public_ip,
    cluster_token     = var.cluster_server_token
  })

  tags = {
    Terraform                                   = "true"
    Environment                                 = "dev"
    Name                                        = "master-3"
    "kubernetes.io/role"                        = "master"
    "KubernetesCluster"                         = var.cluster_name
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  depends_on = [null_resource.echo_master_ip]

}

# copying information from master node.

resource "null_resource" "copy-kubeconfig" {
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ec2-user@${aws_instance.master-node-12.public_ip}:/etc/rancher/k3s/k3s.yaml ./k3s-kubeconfig.yaml"
  }
  depends_on = [null_resource.echo_master_ip]
}

resource "null_resource" "copy-nodetoken" {
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ec2-user@${aws_instance.master-node-12.public_ip}:/home/ec2-user/node-token ./node-token"
  }
  depends_on = [null_resource.echo_master_ip]
}
