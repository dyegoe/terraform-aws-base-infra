output "ssh" {
  value = {
    port              = var.ssh.port
    allow_cidr_blocks = var.ssh.allow_cidr_blocks
  }
}

output "instances" {
  description = "It returns an object of all instances created by the module."
  value = {
    for instance, _ in var.instances : instance => {
      ami                 = nonsensitive(aws_instance.this[instance].ami)
      availability_zone   = data.aws_subnet.ec2_instance[instance].availability_zone
      id                  = aws_instance.this[instance].id
      type                = aws_instance.this[instance].instance_type
      private_ip          = aws_instance.this[instance].private_ip
      public_ip           = aws_eip.ec2_instance[instance].public_ip
      route53             = aws_route53_record.ec2_instance[instance].name
      security_group_id   = module.security_group[instance].security_group_id
      security_group_name = module.security_group[instance].security_group_name
      subnet_id           = data.aws_subnet.ec2_instance[instance].id
      tags                = aws_instance.this[instance].tags
      additional_disks = {
        for disk, v in merge(aws_volume_attachment.create, aws_volume_attachment.create_prevent_destroy) : disk => {
          device_name = v.device_name
          volume_id   = v.volume_id
        } if v.instance_id == aws_instance.this[instance].id
      }
    }
  }
}
