output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = module.vpc.database_subnets
}

output "database_subnet_zone_a" {
  description = "List of IDs of database subnets"
  value       = module.vpc.database_subnets[0]
}


output "database_subnet_zone_b" {
  description = "List of IDs of database subnets"
  value       = module.vpc.database_subnets[1]
}

output "database_subnet_zone_c" {
  description = "List of IDs of database subnets"
  value       = module.vpc.database_subnets[2]
}
