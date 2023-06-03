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
  zone_domain          = "${local.resource_name_prefix}.${var.zone_domain}"
  ##### Merge default sg rules with instance sg rules
  instances_egress_sg_rules_merged = {
    for instance, i in var.instances :
    instance => i.add_default_egress_sg_rules == false ? i.egress_sg_rules : merge(var.default_egress_sg_rules, i.egress_sg_rules)
  }
  instances_ingress_sg_rules_merged = {
    for instance, i in var.instances :
    instance => merge(
      i.add_default_ingress_sg_rules == false ? i.ingress_sg_rules : merge(var.default_ingress_sg_rules, i.ingress_sg_rules),
      { default_ssh = { from_port = var.ssh.port, to_port = var.ssh.port, ip_protocol = "tcp", cidr_ipv4 = var.ssh.allowed_cidr_blocks, description = "SSH Port - Default rules" } }
    )
  }
  ##### Temporary transformation of egress sg rules
  instances_egress_sg_rules_tmp = [
    for instance, i in var.instances : [
      for rule, r in local.instances_egress_sg_rules_merged[instance] : [
        for c, cidr_ipv4 in r.cidr_ipv4 : {
          name        = "${instance}_${rule}_${c}"
          instance    = instance
          rule        = rule
          cidr_index  = c
          from_port   = r.from_port
          to_port     = r.to_port
          ip_protocol = r.ip_protocol
          cidr_ipv4   = cidr_ipv4
          description = r.description
        }
      ]
    ]
  ]
  #### Create a map of egress sg rules
  instances_egress_sg_rules = {
    for _, rule in flatten(local.instances_egress_sg_rules_tmp) : rule.name => {
      instance    = rule.instance
      rule        = rule.rule
      cidr_index  = rule.cidr_index
      from_port   = rule.from_port
      to_port     = rule.to_port
      ip_protocol = rule.ip_protocol
      cidr_ipv4   = rule.cidr_ipv4
      description = rule.description
    }
  }
  ##### Temporary transformation of ingress sg rules
  instances_ingress_sg_rules_tmp = [
    for instance, i in var.instances : [
      for rule, r in local.instances_ingress_sg_rules_merged[instance] : [
        for c, cidr_ipv4 in r.cidr_ipv4 : {
          name        = "${instance}_${rule}_${c}"
          instance    = instance
          rule        = rule
          cidr_index  = c
          from_port   = r.from_port
          to_port     = r.to_port
          ip_protocol = r.ip_protocol
          cidr_ipv4   = cidr_ipv4
          description = r.description
        }
      ]
    ]
  ]
  #### Create a map of ingress sg rules
  instances_ingress_sg_rules = {
    for _, rule in flatten(local.instances_ingress_sg_rules_tmp) : rule.name => {
      instance    = rule.instance
      rule        = rule.rule
      cidr_index  = rule.cidr_index
      from_port   = rule.from_port
      to_port     = rule.to_port
      ip_protocol = rule.ip_protocol
      description = rule.description
      cidr_ipv4   = rule.cidr_ipv4
    }
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
  ##### Pre-defined AMIs
  ami_ids = {
    amzn2      = data.aws_ssm_parameter.amzn2.value
    al2023     = data.aws_ssm_parameter.al2023.value
    ubuntu2204 = data.aws_ssm_parameter.ubuntu2204.value
  }
}

data "aws_region" "current" {}

data "aws_default_tags" "current" {}

data "aws_route53_zone" "current" { name = var.zone_domain }

##### Pre-defined AMIs
data "aws_ssm_parameter" "amzn2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_ssm_parameter" "ubuntu2204" {
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

##### Lookup for the subnet id to place the instance
data "aws_subnet" "instance" {
  for_each = var.instances

  vpc_id            = module.vpc.vpc_id
  availability_zone = "${data.aws_region.current.name}${each.value.availability_zone}"
  tags              = data.aws_default_tags.current.tags

  depends_on = [module.vpc]
}
