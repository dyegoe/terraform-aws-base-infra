/*
 * # Terraform AWS Base Infra
 *
 * This module itends to deploy some base infrasctructure to AWS.
 *
 * It creates:
 *
 * - VPC with public subnets (IPv4 only)
 * - Security Group with SSH access
 * - EIPs
 * - Network interfaces
 * - EC2 instances
 * - Route53 records
 *
 */

locals {
  resource_name_prefix = var.project
  azs                  = formatlist("${data.aws_region.current.name}%s", var.vpc.azs)
  ##### Transform ingress rules cidr to string. It is needed by the security group module
  ingress_sg_rules = [
    for _, rule in var.ingress_sg_rules : {
      from_port   = rule.from_port
      to_port     = rule.to_port
      protocol    = rule.protocol
      description = rule.description
      cidr_blocks = join(",", rule.cidr_blocks)
    }
  ]
  ingress_sg_rules_instances = {
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
  ##### Temporary transformation of additional disks
  additional_disks_tmp = flatten([
    for instance, i in var.instances : [
      for device_name, d in i.additional_disks : {
        instance          = instance
        availability_zone = "${data.aws_region.current.name}${i.availability_zone}"
        device_name       = device_name
        size              = d.size
        volume_id         = d.volume_id
        prevent_destroy   = d.prevent_destroy
        tags              = merge({ "MountPoint" = d.mount_point }, i.tags)
      }
    ]
  ])
  #### Create a map of additional disks to create and prevent destroy
  additional_disks_to_create_prevent_destroy = {
    for _, a in local.additional_disks_tmp : "${a.instance}_${a.device_name}" => {
      instance          = a.instance
      availability_zone = a.availability_zone
      device_name       = a.device_name
      size              = a.size
      tags              = a.tags
    } if a.volume_id == "" && a.prevent_destroy == true
  }
  #### Create a map of additional disks to create
  additional_disks_to_create = {
    for _, a in local.additional_disks_tmp : "${a.instance}_${a.device_name}" => {
      instance          = a.instance
      availability_zone = a.availability_zone
      device_name       = a.device_name
      size              = a.size
      tags              = a.tags
    } if a.volume_id == "" && a.prevent_destroy == false
  }
  #### Create a map of additional disks to attach
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

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_default_tags" "current" {}

data "aws_route53_zone" "current" { name = var.zone_domain }

##### Lookup for the subnet id to place the instance
data "aws_subnet" "ec2_instance" {
  for_each = var.instances

  vpc_id            = module.vpc.vpc_id
  availability_zone = "${data.aws_region.current.name}${each.value.availability_zone}"
  tags              = data.aws_default_tags.current.tags

  depends_on = [module.vpc]
}
