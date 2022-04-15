# Docs: https://www.terraform.io/docs/providers/aws/index.html
provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region

  default_tags {
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
}
