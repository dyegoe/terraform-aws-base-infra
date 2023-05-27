resource "aws_network_interface" "ec2_instance" {
  for_each = var.instances

  subnet_id       = data.aws_subnet.ec2_instance[each.key].id
  security_groups = [module.security_group[each.key].security_group_id]

  tags = merge(
    {
      Name     = "${local.resource_name_prefix}-${each.key}"
      Instance = each.key
    },
    each.value.tags
  )

  depends_on = [
    module.vpc,
    module.security_group,
  ]
}
