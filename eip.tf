resource "aws_eip" "instance" {
  for_each = {
    for instance, i in var.instances : instance => {
      tags = i.tags
    } if i.assign_public_ip == null ? var.assign_public_ip : i.assign_public_ip
  }

  tags = merge(
    {
      Name               = "${local.resource_name_prefix}-${each.key}"
      Instance           = each.key
      NetworkInterfaceId = aws_network_interface.instance[each.key].id
    },
    each.value.tags
  )

  depends_on = [module.vpc]
}

resource "aws_eip_association" "instance" {
  for_each = {
    for instance, i in aws_eip.instance : instance => {
      tags = i.tags
    }
  }

  network_interface_id = aws_network_interface.instance[each.key].id
  allocation_id        = aws_eip.instance[each.key].id

  depends_on = [module.vpc]
}
