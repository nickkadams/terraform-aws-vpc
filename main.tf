provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.78.0"

  name = lower(var.tag_name)

  cidr = var.aws_network

  # 3-AZs
  azs             = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1], data.aws_availability_zones.available.names[2]]
  public_subnets  = [cidrsubnet(var.aws_network, 3, 0), cidrsubnet(var.aws_network, 3, 2), cidrsubnet(var.aws_network, 3, 4)]
  private_subnets = [cidrsubnet(var.aws_network, 3, 1), cidrsubnet(var.aws_network, 3, 3), cidrsubnet(var.aws_network, 3, 5)]

  # 2-AZs
  # azs             = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  # public_subnets  = [cidrsubnet(var.aws_network, 2, 0), cidrsubnet(var.aws_network, 2, 2)]
  # private_subnets = [cidrsubnet(var.aws_network, 2, 1), cidrsubnet(var.aws_network, 2, 3)]

  # IPv6
  enable_ipv6                     = false
  assign_ipv6_address_on_creation = false

  # NAT/VPN
  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false

  # DNS options
  enable_dns_hostnames             = true
  enable_dns_support               = true
  enable_dhcp_options              = true
  dhcp_options_domain_name         = var.domain_name
  dhcp_options_domain_name_servers = ["AmazonProvidedDNS"]

  # Gateway endpoint for S3
  enable_s3_endpoint = true

  # Gateway endpoint for DynamoDB
  enable_dynamodb_endpoint = true

  # Default security group - ingress/egress rules cleared to deny all
  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = []

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  # enable_flow_log                      = true
  # create_flow_log_cloudwatch_log_group = true
  # create_flow_log_cloudwatch_iam_role  = true
  # flow_log_max_aggregation_interval    = 60
  # flow_log_destination_type            = "s3"
  # flow_log_destination_arn             = s3_bucket.this_s3_bucket_arn

  tags = {
    Environment     = var.tag_env
    Contact         = var.tag_cont
    Cost            = var.tag_cost
    Customer        = var.tag_cust
    Project         = var.tag_proj
    Confidentiality = var.tag_conf
    Compliance      = var.tag_comp
    Terraform       = "true"
  }

  default_security_group_tags = {
    Name = "${lower(var.tag_name)}-default"
  }

  private_subnet_tags = {
    Tier = "private"
  }

  public_subnet_tags = {
    Tier = "public"
  }

  vpc_endpoint_tags = {
    Name = lower(var.tag_name)
  }

  # vpc_flow_log_tags = {
  #   Name = lower(var.tag_name)
  # }  
}

resource "aws_db_subnet_group" "this" {
  name       = lower(var.tag_name)
  subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]]
  # subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]

  tags = {
    Environment     = var.tag_env
    Contact         = var.tag_cont
    Cost            = var.tag_cost
    Customer        = var.tag_cust
    Project         = var.tag_proj
    Confidentiality = var.tag_conf
    Compliance      = var.tag_comp
    Terraform       = "true"
    Tier            = "private"
  }
}

resource "aws_elasticache_subnet_group" "this" {
  name       = lower(var.tag_name)
  subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]]
  # subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]

  # tags = {
  #   Environment     = var.tag_env
  #   Contact         = var.tag_cont
  #   Cost            = var.tag_cost
  #   Customer        = var.tag_cust
  #   Project         = var.tag_proj
  #   Confidentiality = var.tag_conf
  #   Compliance      = var.tag_comp
  #   Terraform       = "true"
  # }
}
