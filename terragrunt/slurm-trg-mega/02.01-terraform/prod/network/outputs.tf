output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.network_id
}

output "subnets" {
  description = "Subnets"
  value       = module.vpc.subnets
}

