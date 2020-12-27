variable "region" {
  type    = string
  default = "us-east-2"
}

variable "profile" {
  type    = string
  default = "default"
}

# copy token from master node and paste here.
variable "k3s_token" {
  type    = string
  default = "K1070738a397125f51437451d08bb7da647c6f245f3c627e623a53ad3b691cd9305::server:randomstring123"
}

variable "asg-enable-metrics" {
  type    = list(string)
  default = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
}

variable "cluster_name" {
  type    = string
  default = "urban-spot"
}

variable "ami_id" {
  type    = string
  default = "ami-026dea5602e368e96"
}

variable "worker_instance_type" {
  type    = string
  default = "t3a.micro"
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
