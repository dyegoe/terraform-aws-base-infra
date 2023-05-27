resource "aws_eip" "ec2_instance" {
  for_each = var.instances

  tags = merge(
    {
      Name     = "${local.resource_name_prefix}-${each.key}"
      Instance = each.key
    },
    each.value.tags
  )

  depends_on = [module.vpc]
}

resource "aws_eip_association" "ec2_instance" {
  for_each = var.instances

  network_interface_id = aws_network_interface.ec2_instance[each.key].id
  allocation_id        = aws_eip.ec2_instance[each.key].id

  depends_on = [
    module.vpc,
    aws_eip.ec2_instance,
    aws_network_interface.ec2_instance,
  ]
}
