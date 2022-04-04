# https://wolfman.dev/posts/exclude-use1-az3/
data "aws_availability_zones" "available" {
  state            = "available"
  exclude_zone_ids = ["use1-az3"]
}

data "aws_caller_identity" "current" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.13"

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

  # Disable public IP by default
  map_public_ip_on_launch = false

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

  # Default route table with 0 subnet associations
  manage_default_route_table = true

  default_route_table_tags = {
    Name = "${lower(var.tag_name)}-default"
  }

  # Default security group - ingress/egress rules cleared to deny all
  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = []

  default_security_group_tags = {
    Name = "${lower(var.tag_name)}-default"
  }

  private_subnet_tags = {
    Tier = "private"
  }

  public_subnet_tags = {
    Tier = "public"
  }

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  # enable_flow_log                      = true
  # create_flow_log_cloudwatch_log_group = true
  # create_flow_log_cloudwatch_iam_role  = true
  # flow_log_max_aggregation_interval    = 60
  # flow_log_destination_type            = "s3"
  # flow_log_destination_arn             = s3_bucket.this_s3_bucket_arn

  # vpc_flow_log_tags = {
  #   Name = lower(var.tag_name)
  # }
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

data "aws_vpc_endpoint_service" "dynamodb" {
  service = "dynamodb"

  filter {
    name   = "service-type"
    values = ["Gateway"]
  }
}

data "aws_iam_policy_document" "dynamodb_endpoint_policy" {
  statement {
    effect    = "Deny"
    actions   = ["dynamodb:*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:sourceVpce"

      values = [data.aws_vpc_endpoint_service.dynamodb.id]
    }
  }
}

module "vpc_endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [data.aws_security_group.default.id]

  endpoints = {
    s3 = {
      service      = "s3"
      service_type = "Gateway"

      tags = {
        Name = lower(var.tag_name)
      }
    },
    dynamodb = {
      service         = "dynamodb"
      service_type    = "Gateway"
      route_table_ids = flatten([module.vpc.intra_route_table_ids, module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
      policy          = data.aws_iam_policy_document.dynamodb_endpoint_policy.json

      tags = {
        Name = lower(var.tag_name)
      }
    }
  }
}

resource "aws_db_subnet_group" "this" {
  name       = lower(var.tag_name)
  subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]]
  # subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]

  tags = {
    Tier = "private"
  }
}

resource "aws_elasticache_subnet_group" "this" {
  name       = lower(var.tag_name)
  subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]]
  # subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]

  tags = {
    Tier = "private"
  }
}