provider "aws" {
  region  = "us-east-2"
  profile = "default"
}

module "prashant-vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "prashant-vpc"
  cidr = "10.0.0.0/16"

  azs = ["us-east-2a"]
  # private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets = ["10.0.101.0/24"]

  enable_nat_gateway   = false
  single_nat_gateway   = false
  reuse_nat_ips        = false # should this be true? Yes, for production use case. 
  enable_vpn_gateway   = false
  enable_dns_hostnames = true

  tags = {
    Terraform                                   = "true"
    Environment                                 = "dev"
    Name                                        = "prashant-vpc"
    "KubernetesCluster"                         = var.cluster_name
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}


resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.deployer-public-key
}


resource "aws_security_group_rule" "all_public_access" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.prashant-vpc.default_security_group_id

}

# data "aws_ami" "ubuntu-1804" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = ["099720109477"] # Canonical
# }


resource "aws_iam_role" "k3s-master-role" {
  name               = "k3s-master-role"
  assume_role_policy = file("data/master_iam_policy.json")
}

resource "aws_iam_instance_profile" "k3s-master-role-profile" {
  name = "k3s-master-role-profile"
  role = aws_iam_role.k3s-master-role.name
}

resource "aws_iam_policy" "master_policy" {
  name        = "master-policy"
  description = "Policy for master"
  policy      = file("data/master_policy.json")
}

resource "aws_iam_role_policy_attachment" "master_attach_policy" {
  role       = aws_iam_role.k3s-master-role.name
  policy_arn = aws_iam_policy.master_policy.arn
}

resource "aws_iam_policy" "ccm_policy" {
  name        = "ccm-policy"
  description = "Policy for ccm"
  policy      = file("data/ccm_master_policy.json")
}

resource "aws_iam_role_policy_attachment" "ccm_attach_policy" {
  role       = aws_iam_role.k3s-master-role.name
  policy_arn = aws_iam_policy.ccm_policy.arn
}




resource "aws_instance" "master-node-12" {
  ami                  = "ami-026dea5602e368e96"
  instance_type        = "t3a.large"
  subnet_id            = module.prashant-vpc.public_subnets[0]
  key_name             = aws_key_pair.deployer.key_name
  iam_instance_profile = aws_iam_instance_profile.k3s-master-role-profile.id
  # vpc_security_group_ids = [module.bastion.private_instances_security_group]

  # user_data = templatefile("server-init.tmpl", { cluster_name = var.cluster_name })

  tags = {
    Terraform                                   = "true"
    Environment                                 = "dev"
    Name                                        = "master"
    "kubernetes.io/role"                        = "master"
    "KubernetesCluster"                         = var.cluster_name
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  depends_on = [
    module.prashant-vpc.vpc_id,
  ]

}

resource "aws_instance" "master-node-11" {
  ami                  = "ami-026dea5602e368e96"
  instance_type        = "t3a.large"
  subnet_id            = module.prashant-vpc.public_subnets[0]
  key_name             = aws_key_pair.deployer.key_name
  iam_instance_profile = aws_iam_instance_profile.k3s-master-role-profile.id
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
    module.prashant-vpc.vpc_id,
  ]

}

resource "aws_instance" "master-node-10" {
  ami                  = "ami-026dea5602e368e96"
  instance_type        = "t3a.large"
  subnet_id            = module.prashant-vpc.public_subnets[0]
  key_name             = aws_key_pair.deployer.key_name
  iam_instance_profile = aws_iam_instance_profile.k3s-master-role-profile.id
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
    module.prashant-vpc.vpc_id,
  ]

}

# resource "null_resource" "echo_master_ip" {
#   provisioner "local-exec" {
#     command = "sleep 120s && echo ${aws_instance.master-node-12.public_ip}"
#   }
#   depends_on = [
#     null_resource.echo_master_ip,
#     module.prashant-vpc.vpc_id
#   ]
# }

# resource "null_resource" "copy-kubeconfig" {
#   provisioner "local-exec" {
#     command = "sleep 10s && scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${aws_instance.master-node-12.public_ip}:/etc/rancher/k3s/k3s.yaml ./k3s-kubeconfig.yaml"
#   }
#   depends_on = [null_resource.echo_master_ip]
# }

# resource "null_resource" "copy-nodetoken" {
#   provisioner "local-exec" {
#     command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${aws_instance.master-node-12.public_ip}:/home/ubuntu/node-token ./node-token"
#   }
#   depends_on = [null_resource.echo_master_ip]
# }

resource "aws_instance" "worker-node-12" {
  ami                  = "ami-026dea5602e368e96"
  instance_type        = "t3.micro"
  subnet_id            = module.prashant-vpc.public_subnets[0]
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

  depends_on = [
    aws_instance.master-node-12
  ]

}

resource "aws_instance" "worker-node-11" {
  ami                  = "ami-026dea5602e368e96"
  instance_type        = "t3.micro"
  subnet_id            = module.prashant-vpc.public_subnets[0]
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

  depends_on = [
    aws_instance.master-node-12
  ]

}
