variable "region" {
  type    = string
  default = "us-east-2"
}

variable "profile" {
  type    = string
  default = "default"
}

variable "deployer-public-key" {
  type    = string
}

variable "cluster_name" {
  type    = string
  default = "k3s-demo"
}

variable "ami_id" {
  type    = string
  default = "ami-026dea5602e368e96"
}

variable "master_instance_type" {
  type    = string
  default = "t3a.large"
}

variable "cluster_server_token" {
  type = string
  default = "randomstring123"
}

variable "public_subnet_cidr_blocks" {
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

# ALERT!!!! copy these from output of vpc module.
variable "private_subnet_cidr_blocks" {
  type    = list(string)
  default = []
}
