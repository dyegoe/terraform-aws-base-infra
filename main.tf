locals {
  resource_name_prefix = var.project
  azs                  = formatlist("${data.aws_region.current.name}%s", var.vpc.azs)
  zone_domain          = "${local.resource_name_prefix}.${var.zone_domain}"
  ##### Create a map of shared security groups egress rules
  shared_security_group_egress_rules = {
    for _, v in flatten([
      for security_group, sg in var.security_groups : [
        concat(
          [
            for rule, r in sg["egress"] : [
              for c, cidr in r.cidr_ipv4 : {
                name           = "${security_group}_${rule}_${c}"
                security_group = security_group
                rule           = rule
                cidr_index     = c
                from_port      = r.from_port
                to_port        = r.to_port
                ip_protocol    = r.ip_protocol
                cidr_ipv4      = cidr
                self           = false
                description    = r.description
              }
            ] if r.cidr_ipv4 != null ? length(r.cidr_ipv4) > 0 : false
          ],
          [
            for rule, r in sg["egress"] : [{
              name           = "${security_group}_${rule}"
              security_group = security_group
              rule           = rule
              cidr_index     = 0
              from_port      = r.from_port
              to_port        = r.to_port
              ip_protocol    = r.ip_protocol
              cidr_ipv4      = null
              self           = r.self
              description    = r.description
            }] if r.self != null && r.self == true
          ]
        )
      ] if sg["egress"] != null
    ]) : v.name => v
  }
  ##### Create a map of shared security groups ingress rules
  shared_security_group_ingress_rules = {
    for _, v in flatten([
      for security_group, sg in var.security_groups : [
        concat(
          [
            for rule, r in sg["ingress"] : [
              for c, cidr in r.cidr_ipv4 : {
                name           = "${security_group}_${rule}_${c}"
                security_group = security_group
                rule           = rule
                cidr_index     = c
                from_port      = r.from_port
                to_port        = r.to_port
                ip_protocol    = r.ip_protocol
                cidr_ipv4      = cidr
                self           = false
                description    = r.description
              }
            ] if r.cidr_ipv4 != null ? length(r.cidr_ipv4) > 0 : false
          ],
          [
            for rule, r in sg["ingress"] : [{
              name           = "${security_group}_${rule}"
              security_group = security_group
              rule           = rule
              cidr_index     = 0
              from_port      = r.from_port
              to_port        = r.to_port
              ip_protocol    = r.ip_protocol
              cidr_ipv4      = null
              self           = r.self
              description    = r.description
            }] if r.self != null && r.self == true
          ]
        )
      ] if sg["ingress"] != null
    ]) : v.name => v
  }
  ##### Merge default sg rules with instance sg rules
  instances_security_group_egress_rules_merged = {
    for instance, i in var.instances :
    instance => i.add_default_egress_sg_rules == false ? i.egress_sg_rules : merge(var.default_egress_sg_rules, i.egress_sg_rules)
  }
  instances_security_group_ingress_rules_merged = {
    for instance, i in var.instances :
    instance => i.add_default_ingress_sg_rules == false ? i.ingress_sg_rules : merge(var.default_ingress_sg_rules, i.ingress_sg_rules)
  }
  #### Create a map of instances egress sg rules
  instances_security_group_egress_rules = {
    for _, rule in flatten([
      for instance, i in var.instances : [
        for rule, r in local.instances_security_group_egress_rules_merged[instance] : [
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
    ]) : rule.name => rule
  }
  #### Create a map of instances ingress sg rules
  instances_security_group_ingress_rules = {
    for _, rule in flatten([
      for instance, i in var.instances : [
        for rule, r in local.instances_security_group_ingress_rules_merged[instance] : [
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
    ]) : rule.name => rule
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
        tags              = merge({ "MountPoint" = d.mount_point, "MountMode" = d.mount_mode }, i.tags)
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
  ##### Create a map of instances that need to associate a public ip
  instances_with_public_ip = {
    for instance, i in var.instances : instance => {
      tags = i.tags
    } if i.assign_public_ip == null ? var.assign_public_ip : i.assign_public_ip
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
