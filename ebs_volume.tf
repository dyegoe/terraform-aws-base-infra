##### Create volumes #####
resource "aws_ebs_volume" "create" {
  for_each          = local.additional_disks_to_create
  availability_zone = each.value.availability_zone
  size              = each.value.size
  type              = var.volume_type
  tags = merge(
    {
      "Name" = "${var.resource_name_prefix}-${each.value.instance}-${each.value.device_name}"
    },
    each.value.tags
  )
  lifecycle {
    prevent_destroy = true
  }
}

#### Attach created volumes to the instance #####
resource "aws_volume_attachment" "create" {
  for_each    = local.additional_disks_to_create
  device_name = "/dev/${each.value.device_name}"
  volume_id   = aws_ebs_volume.create[each.key].id
  instance_id = aws_instance.this[each.value.instance].id
}

#### Attach volumes to the instances #####
resource "aws_volume_attachment" "attach" {
  for_each    = local.additional_disks_to_attach
  device_name = "/dev/${each.value.device_name}"
  volume_id   = each.value.volume_id
  instance_id = aws_instance.this[each.value.instance].id
}
