resource "aws_security_group" "instance" {
  for_each = var.instances

  name        = substr("${local.resource_name_prefix}-${each.key}-instance-sg-${random_id.instance_sg[each.key].hex}", 0, 64)
  vpc_id      = module.vpc.vpc_id
  description = "Security group for instance ${each.key}"

  tags = {
    Name     = "${local.resource_name_prefix}-${each.key}-instance-sg"
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
  for_each = local.instances_security_group_egress_rules

  security_group_id = aws_security_group.instance[each.value.instance].id

  from_port   = each.value.from_port
  to_port     = each.value.to_port
  ip_protocol = each.value.ip_protocol
  cidr_ipv4   = each.value.cidr_ipv4
  description = each.value.description

  tags = {
    Name     = "${local.resource_name_prefix}-${each.value.instance}-instance-sg-egress-rule-${each.value.rule}-${each.value.cidr_index}"
    Instance = each.value.instance
  }

  depends_on = [aws_security_group.instance]
}

resource "aws_vpc_security_group_ingress_rule" "instance" {
  for_each = local.instances_security_group_ingress_rules

  security_group_id = aws_security_group.instance[each.value.instance].id

  from_port   = each.value.from_port
  to_port     = each.value.to_port
  ip_protocol = each.value.ip_protocol
  cidr_ipv4   = each.value.cidr_ipv4
  description = each.value.description

  tags = {
    Name     = "${local.resource_name_prefix}-${each.value.instance}-instance-sg-ingress-rule-${each.value.rule}-${each.value.cidr_index}"
    Instance = each.value.instance
  }

  depends_on = [aws_security_group.instance]
}

resource "aws_security_group" "shared" {
  for_each = var.security_groups

  name        = substr("${local.resource_name_prefix}-${each.key}-shared-sg-${random_id.shared_sg[each.key].hex}", 0, 64)
  vpc_id      = module.vpc.vpc_id
  description = each.value.description

  tags = {
    Name = "${local.resource_name_prefix}-${each.key}-shared-sg"
  }

  lifecycle {
    create_before_destroy = true
  }

  timeouts {
    delete = "2m"
  }

  depends_on = [module.vpc]
}

resource "aws_vpc_security_group_egress_rule" "shared" {
  for_each = local.shared_security_group_egress_rules

  security_group_id = aws_security_group.shared[each.value.security_group].id

  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  ip_protocol                  = each.value.ip_protocol
  cidr_ipv4                    = each.value.self ? null : each.value.cidr_ipv4
  referenced_security_group_id = each.value.self ? aws_security_group.shared[each.value.security_group].id : null
  description                  = each.value.description

  tags = {
    Name = "${local.resource_name_prefix}-shared-sg-egress-rule-${each.value.rule}-${each.value.cidr_index}"
  }

  depends_on = [aws_security_group.shared]
}

resource "aws_vpc_security_group_ingress_rule" "shared" {
  for_each = local.shared_security_group_ingress_rules

  security_group_id = aws_security_group.shared[each.value.security_group].id

  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  ip_protocol                  = each.value.ip_protocol
  cidr_ipv4                    = each.value.self ? null : each.value.cidr_ipv4
  referenced_security_group_id = each.value.self ? aws_security_group.shared[each.value.security_group].id : null
  description                  = each.value.description

  tags = {
    Name = "${local.resource_name_prefix}-shared-sg-ingress-rule-${each.value.rule}-${each.value.cidr_index}"
  }

  depends_on = [aws_security_group.shared]
}
