/*provider "aws" {
  region = var.aws_region
}*/

resource "aws_security_group" "sec_group" {
  name_prefix = "reflexive-port-${var.port_num}"
  description = "Allow outbound to world"
  vpc_id      = var.vpc_id

  tags = {
    Name = "reflexive-port-${var.port_num}"
  }
}

resource "aws_security_group_rule" "allow_from_self" {
  type                     = "ingress"
  from_port                = var.port_num
  to_port                  = var.port_num
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sec_group.id
  source_security_group_id = aws_security_group.sec_group.id
}