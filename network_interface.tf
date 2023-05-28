resource "aws_network_interface" "ec2_instance" {
  for_each = var.instances

  subnet_id       = data.aws_subnet.ec2_instance[each.key].id
  security_groups = [aws_security_group.instance[each.key].id]

  tags = merge(
    {
      Name     = "${local.resource_name_prefix}-${each.key}"
      Instance = each.key
    },
    each.value.tags
  )

  depends_on = [
    module.vpc,
    aws_security_group.instance,
  ]
}
