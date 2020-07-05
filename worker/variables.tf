# copy token from master node and paste here.
variable "k3s_token" {
  type    = string
  default = ""
}

variable "asg-enable-metrics" {
  type    = list(string)
  default = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
}

variable "cluster_name" {
  type    = string
  default = "k3s-demo"
}

variable "ami_id" {
  type    = string
  default = "ami-026dea5602e368e96"
}

variable "worker_instance_type" {
  type    = string
  default = "t3a.micro"
}
