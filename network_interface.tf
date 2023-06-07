resource "aws_network_interface" "instance" {
  for_each = var.instances

  subnet_id = data.aws_subnet.instance[each.key].id
  security_groups = concat(
    [aws_security_group.instance[each.key].id],
    [for sg in each.value.additional_security_groups : aws_security_group.shared[sg].id]
  )

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
    aws_security_group.shared
  ]
}
