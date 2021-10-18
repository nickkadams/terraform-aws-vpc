resource "aws_eip" "bastion" {
  count = 2

  vpc              = true
  public_ipv4_pool = "amazon"

  tags = {
    Name = "${var.tag_name}-bastion-${format("%03d", count.index + 1)}"
  }
}