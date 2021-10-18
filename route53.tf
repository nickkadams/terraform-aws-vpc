locals {
  domain      = var.domain_name
  domain_name = lower(trimsuffix(var.domain_name, "."))
}

resource "aws_route53_zone" "private" {
  name    = local.domain_name
  comment = "Managed by Terraform"

  vpc {
    vpc_id = module.vpc.vpc_id
  }

  lifecycle {
    ignore_changes = [vpc]
  }
}