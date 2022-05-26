locals {
  ##### Transform ingress rules cidr to string. It is needed by the security group module #####
  ingress_with_cidr_blocks = {
    for instance, v in var.instances : instance => [
      for _, rule in v.ingress_sg_rules : {
        from_port   = rule.from_port
        to_port     = rule.to_port
        protocol    = rule.protocol
        description = rule.description
        cidr_blocks = join(",", rule.cidr_blocks)
      }
    ]
  }
  ##### Temporary transformation of additional disks #####
  additional_disks_tmp = flatten([
    for instance, _ in var.instances : [
      for device_name, size in var.instances[instance].additional_disks : {
        instance          = instance
        availability_zone = var.instances[instance].availability_zone
        device_name       = device_name
        size              = size
        tags              = var.instances[instance].tags
      }
    ]
  ])
  #### Create a map of additional disks to iterate #####
  additional_disks = {
    for _, additional_disk in local.additional_disks_tmp : "${additional_disk.instance}_${additional_disk.device_name}" => {
      instance          = additional_disk.instance
      availability_zone = additional_disk.availability_zone
      device_name       = additional_disk.device_name
      size              = additional_disk.size
      tags              = additional_disk.tags
    }
  }
}
