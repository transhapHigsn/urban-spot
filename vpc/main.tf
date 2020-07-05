provider "aws" {
  region  = var.region
  profile = var.profile
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "dev-vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "dev-vpc"
  cidr = "10.0.0.0/16"

  azs = data.aws_availability_zones.available.names

  # private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway   = false
  single_nat_gateway   = false
  reuse_nat_ips        = false # should this be true? Yes, for production use case. 
  enable_vpn_gateway   = false
  enable_dns_hostnames = true

  tags = {
    Terraform                                   = "true"
    Environment                                 = "dev"
    Name                                        = "dev-vpc"
    "KubernetesCluster"                         = var.cluster_name
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_security_group_rule" "all_public_access" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.dev-vpc.default_security_group_id

}
