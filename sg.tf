# Get my IP
data "http" "icanhazip" {
  url = "http://icanhazip.com"
}

module "sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.18.0"

  name            = "mgmt"
  use_name_prefix = false
  description     = "Managed by Terraform"
  vpc_id          = module.vpc.vpc_id

  ingress_cidr_blocks = ["${chomp(data.http.icanhazip.body)}/32"]
  ingress_rules       = ["ssh-tcp", "rdp-tcp"]

  egress_cidr_blocks      = ["0.0.0.0/0"]
  egress_ipv6_cidr_blocks = ["::/0"]
  egress_rules            = ["all-all"]

  tags = {
    Packer = "true"
  }
}
