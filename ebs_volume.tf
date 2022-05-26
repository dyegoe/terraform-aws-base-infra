##### Create volume #####
resource "aws_ebs_volume" "this" {
  for_each          = local.additional_disks
  availability_zone = each.value.availability_zone
  size              = each.value.size
  type              = var.volume_type
  tags = merge(
    {
      "Name" = "${var.resource_name_prefix}-${each.value.instance}"
    },
    each.value.tags
  )
}

#### Attach the volume #####
resource "aws_volume_attachment" "this" {
  for_each    = local.additional_disks
  device_name = "/dev/${each.value.device_name}"
  volume_id   = aws_ebs_volume.this[each.key].id
  instance_id = aws_instance.this[each.value.instance].id
}
