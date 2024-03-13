resource "aws_eip" "jumphost" {
  count = 2

  domain = "vpc"

  tags = {
    Name = "${var.tag_name}-jumphost-${format("%03d", count.index + 1)}"
  }
}
