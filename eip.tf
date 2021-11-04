resource "aws_eip" "jumphost" {
  count = 2

  vpc              = true
  public_ipv4_pool = "amazon"

  tags = {
    Name = "${var.tag_name}-jumphost-${format("%03d", count.index + 1)}"
  }
}