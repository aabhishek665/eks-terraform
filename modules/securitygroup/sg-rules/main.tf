resource "aws_security_group_rule" "inboundwithcidr" {
  count             = length(var.ingress_with_cidr_blocks) > 0 ? length(var.ingress_with_cidr_blocks) : 0
  description       = lookup(element(var.ingress_with_cidr_blocks, count.index), "description")
  from_port         = lookup(element(var.ingress_with_cidr_blocks, count.index), "from_port")
  protocol          = lookup(element(var.ingress_with_cidr_blocks, count.index), "protocol")
  security_group_id = var.security_group_id
  cidr_blocks       = lookup(element(var.ingress_with_cidr_blocks, count.index), "cidr_blocks")
  to_port           = lookup(element(var.ingress_with_cidr_blocks, count.index), "to_port")
  type              = "ingress"
}
resource "aws_security_group_rule" "outboundwithcidr" {
  count             = length(var.egress_with_cidr_blocks) > 0 ? length(var.egress_with_cidr_blocks) : 0
  description       = lookup(element(var.egress_with_cidr_blocks, count.index), "description")
  from_port         = lookup(element(var.egress_with_cidr_blocks, count.index), "from_port")
  protocol          = lookup(element(var.egress_with_cidr_blocks, count.index), "protocol")
  security_group_id = var.security_group_id
  cidr_blocks       = lookup(element(var.egress_with_cidr_blocks, count.index), "cidr_blocks")
  to_port           = lookup(element(var.egress_with_cidr_blocks, count.index), "to_port")
  type              = "egress"
}
resource "aws_security_group_rule" "inboundwithsg" {
  count                    = length(var.ingress_with_sgid) > 0 ? length(var.ingress_with_sgid) : 0
  description              = lookup(element(var.ingress_with_sgid, count.index), "description")
  from_port                = lookup(element(var.ingress_with_sgid, count.index), "from_port")
  protocol                 = lookup(element(var.ingress_with_sgid, count.index), "protocol")
  security_group_id        = var.security_group_id
  source_security_group_id = lookup(element(var.ingress_with_sgid, count.index), "source_security_group_id")
  to_port                  = lookup(element(var.ingress_with_sgid, count.index), "to_port")
  type                     = "ingress"
}
resource "aws_security_group_rule" "outboundwithsg" {
  count                    = length(var.egress_with_sgid) > 0 ? length(var.egress_with_sgid) : 0
  description              = lookup(element(var.egress_with_sgid, count.index), "description")
  from_port                = lookup(element(var.egress_with_sgid, count.index), "from_port")
  protocol                 = lookup(element(var.egress_with_sgid, count.index), "protocol")
  security_group_id        = var.security_group_id
  source_security_group_id = lookup(element(var.egress_with_sgid, count.index), "source_security_group_id")
  to_port                  = lookup(element(var.egress_with_sgid, count.index), "to_port")
  type                     = "egress"
}