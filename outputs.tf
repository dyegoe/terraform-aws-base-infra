output "instances" {
  description = "It returns an object of all instances created by the module."
  value = {
    for instance, _ in var.instances : instance => {
      ami                 = nonsensitive(aws_instance.this[instance].ami)
      availability_zone   = data.aws_subnet.instance[instance].availability_zone
      id                  = aws_instance.this[instance].id
      type                = aws_instance.this[instance].instance_type
      private_ip          = aws_instance.this[instance].private_ip
      public_ip           = aws_eip.instance[instance].public_ip
      route53             = aws_route53_record.public[instance].name
      random_id_sg        = random_id.instance_sg[instance].hex
      security_group_id   = aws_security_group.instance[instance].id
      security_group_name = aws_security_group.instance[instance].name
      subnet_id           = data.aws_subnet.instance[instance].id
      tags                = aws_instance.this[instance].tags_all
      additional_disks = {
        for disk, v in merge(aws_volume_attachment.create, aws_volume_attachment.create_prevent_destroy) : disk => {
          device_name = v.device_name
          volume_id   = v.volume_id
        } if v.instance_id == aws_instance.this[instance].id
      }
    }
  }
}

output "shared_security_groups_id" {
  description = "It returns an object of shared security groups id."
  value       = { for k, v in aws_security_group.shared : k => v.id }
}

output "shared_security_group_egress_rules" {
  description = "It returns an object of shared security group egress rules."
  value       = local.shared_security_group_egress_rules
}

output "shared_security_group_ingress_rules" {
  description = "It returns an object of shared security group ingress rules."
  value       = local.shared_security_group_ingress_rules
}

output "instances_security_group_egress_rules" {
  description = "It returns an object of instances security group egress rules."
  value       = local.instances_security_group_egress_rules
}

output "instances_security_group_ingress_rules" {
  description = "It returns an object of instances security group ingress rules."
  value       = local.instances_security_group_ingress_rules
}
