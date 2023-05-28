resource "aws_security_group" "instance" {
  for_each = var.instances

  name   = substr("${local.resource_name_prefix}-${each.key}-sg-${random_id.instance_sg[each.key].hex}", 0, 64)
  vpc_id = module.vpc.vpc_id

  tags = {
    Name     = "${local.resource_name_prefix}-${each.key}-sg"
    Instance = each.key
  }

  lifecycle {
    create_before_destroy = true
  }

  timeouts {
    delete = "2m"
  }

  depends_on = [module.vpc]
}

resource "aws_vpc_security_group_egress_rule" "instance" {
  for_each = local.instances_egress_sg_rules

  security_group_id = aws_security_group.instance[each.value.instance].id

  from_port   = each.value.from_port
  to_port     = each.value.to_port
  ip_protocol = each.value.ip_protocol
  cidr_ipv4   = each.value.cidr_ipv4
  description = each.value.description

  tags = {
    Name     = "${local.resource_name_prefix}-${each.value.instance}-egress-sg-rule-${each.value.rule}-${each.value.cidr_index}"
    Instance = each.value.instance
  }

  depends_on = [aws_security_group.instance]
}

resource "aws_vpc_security_group_ingress_rule" "instance" {
  for_each = local.instances_ingress_sg_rules

  security_group_id = aws_security_group.instance[each.value.instance].id

  from_port   = each.value.from_port
  to_port     = each.value.to_port
  ip_protocol = each.value.ip_protocol
  cidr_ipv4   = each.value.cidr_ipv4
  description = each.value.description

  tags = {
    Name     = "${local.resource_name_prefix}-${each.value.instance}-ingress-sg-rule-${each.value.rule}-${each.value.cidr_index}"
    Instance = each.value.instance
  }

  depends_on = [aws_security_group.instance]
}
