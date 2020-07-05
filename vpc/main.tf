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
