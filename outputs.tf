# Caller
output "account_id" {
  description = "The Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  description = "The Caller ARN"
  value       = data.aws_caller_identity.current.arn
}

output "caller_user" {
  description = "The Caller User"
  value       = data.aws_caller_identity.current.user_id
}

# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_name" {
  description = "The name of the VPC"
  value       = module.vpc.name
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

# Subnets
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = [module.vpc.private_subnets]
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = [module.vpc.public_subnets]
}

# Database
output "rds_subnet_group" {
  description = "RDS DB Subnet Group"
  value       = aws_db_subnet_group.this.id
}

# ElastiCache
output "ec_subnet_group" {
  description = "ElastiCache Subnet Group"
  value       = aws_elasticache_subnet_group.this.id
}

# Security Group
output "mgmt_security_group" {
  description = "Management Security Group"
  value       = module.sg.this_security_group_name
}

# EIP(s)
output "bastion_eips" {
  description = "List of IDs of elastic IPs"
  value       = [aws_eip.bastion[*].id]
}

# Domain name
output "domain_name" {
  description = "Route 53 domain name"
  value       = var.domain_name
}