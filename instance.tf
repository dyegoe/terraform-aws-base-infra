##### Create EC2 instance #####
resource "aws_instance" "this" {
  for_each                = var.instances
  ami                     = each.value.ami_id
  disable_api_termination = false
  ebs_optimized           = true
  instance_type           = each.value.instance_type
  subnet_id               = data.aws_subnet.this[each.key].id
  key_name                = var.key_name
  monitoring              = true
  vpc_security_group_ids  = [module.security_group[each.key].security_group_id]
  user_data_base64        = data.template_cloudinit_config.ec2_instance.rendered
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
        "Name" = "${var.resource_name_prefix}-${each.key}"
      },
      each.value.tags
    )
  }
  tags = merge(
    {
      "Name"        = "${var.resource_name_prefix}-${each.key}"
      "Zone_Domain" = "${var.zone_domain}"
    },
    each.value.tags
  )
}
