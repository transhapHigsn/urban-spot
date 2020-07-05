# copy token from master node and paste here.
variable "deployer-public-key" {
  type    = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCaiU+rxqvqD+OYiab58cRghIO8Pxd6E6XK63GKa+nKjKFaIfAq6q9QdYwZo42hDV0osz3u3tzww8hTczZ0gw9eMqqN9cLgeedu6nSMLInQY/YxsNTjcEB0eCld9iFksru0BkFXPz0ZmWR2bI0oU8qd1GxmRRC70OIb0ACVz48Hj3tuQJpAIn2xX9Ao08jZ735vXCXIX2arqxQ0UJOCkL9f2WEj/eHP6+00kz2FCgb/7dxXh624ivO0PK5P40vOqQnSJnrdwD5BhQ+6nudsGhTQAzdgHWSaCSNAVGA6uuIGylgYkQQHW8yOIzr7cgBW0rJoJDeNoFVOFy3Yjl6s3JFGJFL0FAIvMsDnSNiqVwOZjpWgyrDeY5SReE8xX+lPf/fNnaIyjfEaIGNDwPrTr9hafmeYecoOuX+4UMxPD1DDESF3jiXZWWxJVsXV84A5JOkVyDKtcMm7kuGqeIQbfRqChbbzzAgtgMg6uPPWy0foBMVH9RdpEK9NkkvPoU+e1v8= higsn@saitama"
}

variable "cluster_name" {
  type    = string
  default = "k3s-demo"
}

variable "ami_id" {
    type = string
    default = "ami-026dea5602e368e96"
}

variable "master_instance_type" {
    type = string
    default = "t3a.large"
}