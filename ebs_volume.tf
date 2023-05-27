##### Create volumes prevent destroy #####
resource "aws_ebs_volume" "create_prevent_destroy" {
  for_each          = local.additional_disks_to_create_prevent_destroy
  availability_zone = each.value.availability_zone
  size              = each.value.size
  type              = var.volume_type
  tags = merge(
    {
      Name     = "${local.resource_name_prefix}-${each.value.instance}-${each.value.device_name}"
      Instance = each.value.instance
    },
    each.value.tags
  )

  depends_on = [aws_instance.this]
  lifecycle {
    prevent_destroy = true
  }
}

#### Attach created volumes (prevent destroy) to the instance #####
resource "aws_volume_attachment" "create_prevent_destroy" {
  for_each = local.additional_disks_to_create_prevent_destroy

  device_name                    = "/dev/${each.value.device_name}"
  volume_id                      = aws_ebs_volume.create_prevent_destroy[each.key].id
  instance_id                    = aws_instance.this[each.value.instance].id
  stop_instance_before_detaching = true

  depends_on = [
    aws_instance.this,
    aws_ebs_volume.create_prevent_destroy,
  ]
}

##### Create volumes #####
resource "aws_ebs_volume" "create" {
  for_each = local.additional_disks_to_create

  availability_zone = each.value.availability_zone
  size              = each.value.size
  type              = var.volume_type
  tags = merge(
    {
      Name     = "${local.resource_name_prefix}-${each.value.instance}-${each.value.device_name}"
      Instance = each.value.instance
    },
    each.value.tags
  )

  depends_on = [aws_instance.this]

  lifecycle {
    prevent_destroy = false
  }
}

#### Attach created volumes to the instance #####
resource "aws_volume_attachment" "create" {
  for_each = local.additional_disks_to_create

  device_name                    = "/dev/${each.value.device_name}"
  volume_id                      = aws_ebs_volume.create[each.key].id
  instance_id                    = aws_instance.this[each.value.instance].id
  stop_instance_before_detaching = true

  depends_on = [
    aws_instance.this,
    aws_ebs_volume.create,
  ]
}

#### Attach volumes to the instances #####
resource "aws_volume_attachment" "attach" {
  for_each = local.additional_disks_to_attach

  device_name                    = "/dev/${each.value.device_name}"
  volume_id                      = each.value.volume_id
  instance_id                    = aws_instance.this[each.value.instance].id
  stop_instance_before_detaching = true

  depends_on = [
    aws_instance.this,
  ]
}
