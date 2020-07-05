output "vpc_id" {
  description = "The ID of the Default VPC"
  value       = module.dev-vpc.vpc_id
}

output "default_security_group_id" {
  description = "Default security group of the VPC"
  value       = module.dev-vpc.default_security_group_id
}

output "public_subnets" {
  description = "Public subnet list for the vpc"
  value       = module.dev-vpc.public_subnets
}

output "private_subnets" {
  description = "Private subnet list for the vpc"
  value       = module.dev-vpc.private_subnets
}