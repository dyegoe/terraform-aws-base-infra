##### Create volume #####
resource "aws_ebs_volume" "this" {
  for_each = {
    for _, a in local.additional_disks_tmp : "${a.instance}_${a.device_name}" => {
      instance          = a.instance
      availability_zone = a.availability_zone
      device_name       = a.device_name
      size              = a.size
      tags              = a.tags
    }
  }
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
  for_each = {
    for _, a in local.additional_disks_tmp : "${a.instance}_${a.device_name}" => {
      instance          = a.instance
      availability_zone = a.availability_zone
      device_name       = a.device_name
      size              = a.size
      tags              = a.tags
    }
  }
  device_name = "/dev/${each.value.device_name}"
  volume_id   = aws_ebs_volume.this[each.key].id
  instance_id = aws_instance.this[each.value.instance].id
}
