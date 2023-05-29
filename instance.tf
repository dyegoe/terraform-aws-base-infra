resource "aws_instance" "this" {
  for_each = var.instances

  ami                     = try(local.ami_ids[each.value.ami_id], each.value.ami_id)
  disable_api_termination = false
  ebs_optimized           = true
  instance_type           = each.value.instance_type
  key_name                = each.value.key_name != "" ? each.value.key_name : var.key_name
  monitoring              = false
  user_data_base64        = data.cloudinit_config.instance.rendered

  metadata_options {
    http_endpoint          = "enabled"
    http_tokens            = "required"
    instance_metadata_tags = "enabled"
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  root_block_device {
    delete_on_termination = true
    encrypted             = false
    volume_size           = each.value.disk_size
    volume_type           = var.volume_type
    tags = merge(
      {
        Name     = "${local.resource_name_prefix}-${each.key}"
        Instance = each.key
      },
      each.value.tags
    )
  }

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.instance[each.key].id
  }

  tags = merge(
    {
      Name     = "${local.resource_name_prefix}-${each.key}"
      Instance = each.key
      Hostname = "${each.key}.${local.zone_domain}"
    },
    each.value.tags
  )

  depends_on = [
    module.vpc,
    aws_eip.instance,
    aws_eip_association.instance,
    aws_network_interface.instance,
  ]
}
