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
    for instance, i in var.instances : [
      for device_name, d in i.additional_disks : {
        instance          = instance
        availability_zone = i.availability_zone
        device_name       = device_name
        size              = d.size
        volume_id         = d.volume_id
        prevent_destroy   = d.prevent_destroy == false ? false : true
        tags              = merge({ "mount_point" = d.mount_point, "mount_mode" = d.mount_mode }, i.tags)
      }
    ]
  ])
  #### Create a map of additional disks to create and prevent destroy #####
  additional_disks_to_create_prevent_destroy = {
    for _, a in local.additional_disks_tmp : "${a.instance}_${a.device_name}" => {
      instance          = a.instance
      availability_zone = a.availability_zone
      device_name       = a.device_name
      size              = a.size
      tags              = a.tags
    } if a.volume_id == "" && a.prevent_destroy == true
  }
  #### Create a map of additional disks to create #####
  additional_disks_to_create = {
    for _, a in local.additional_disks_tmp : "${a.instance}_${a.device_name}" => {
      instance          = a.instance
      availability_zone = a.availability_zone
      device_name       = a.device_name
      size              = a.size
      tags              = a.tags
    } if a.volume_id == "" && a.prevent_destroy == false
  }
  #### Create a map of additional disks to attach #####
  additional_disks_to_attach = {
    for _, a in local.additional_disks_tmp : "${a.instance}_${a.device_name}" => {
      instance          = a.instance
      availability_zone = a.availability_zone
      device_name       = a.device_name
      volume_id         = a.volume_id
      tags              = a.tags
    } if a.volume_id != ""
  }
}
