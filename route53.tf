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
}