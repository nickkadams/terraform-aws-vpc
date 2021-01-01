resource "aws_eip" "bastion" {
  count = 2

  vpc              = true
  public_ipv4_pool = "amazon"

  tags = {
    Name            = "${var.tag_name}-bastion-${format("%03d", count.index + 1)}"
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