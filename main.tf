locals {
  name = lower(replace(var.tag_name, ".", "-"))
}

# https://wolfman.dev/posts/exclude-use1-az3/
# https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html#network-requirements-subnets
data "aws_availability_zones" "available" {
  state = "available"
  #exclude_zone_ids = ["use1-az3", "usw1-az2", "cac1-az3"]
}

data "aws_caller_identity" "current" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.5.3"

  name = local.name

  cidr = var.aws_network

  # 3-AZs
  # ipcalc 172.18.0.0/16 --split 14 14 14 14 14 14 4094 4094 4094 16382 16382 16382
  azs                 = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1], data.aws_availability_zones.available.names[2]]
  public_subnets      = [cidrsubnet(var.aws_network, 4, 12), cidrsubnet(var.aws_network, 4, 13), cidrsubnet(var.aws_network, 4, 14)]
  private_subnets     = [cidrsubnet(var.aws_network, 2, 0), cidrsubnet(var.aws_network, 2, 1), cidrsubnet(var.aws_network, 2, 2)]
  intra_subnets       = [cidrsubnet(var.aws_network, 12, 3843), cidrsubnet(var.aws_network, 12, 3844), cidrsubnet(var.aws_network, 12, 3845)]
  elasticache_subnets = [cidrsubnet(var.aws_network, 12, 3840), cidrsubnet(var.aws_network, 12, 3841), cidrsubnet(var.aws_network, 12, 3842)]

  # Intra
  intra_subnet_suffix = "tgw"

  # Elasticache
  elasticache_subnet_suffix             = "eks"
  create_elasticache_subnet_group       = false
  create_elasticache_subnet_route_table = true

  # ACLs
  public_dedicated_network_acl  = true
  private_dedicated_network_acl = false
  intra_dedicated_network_acl   = true

  # https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html#vpc-cidr
  map_public_ip_on_launch = true

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
    Name = "${local.name}-default"
  }

  # Default security group - ingress/egress rules cleared to deny all
  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = []

  default_security_group_tags = {
    Name = "${local.name}-default"
  }

  private_subnet_tags = {
    Tier                              = "private"
    "kubernetes.io/role/internal-elb" = 1
    # Tag subnets for Karpenter auto-discovery
    "karpenter.sh/discovery" = local.name
  }

  public_subnet_tags = {
    Tier                     = "public"
    "kubernetes.io/role/elb" = 1
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
