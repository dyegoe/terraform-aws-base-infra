# Terraform AWS Base Infra

This module itends to deploy some base infrasctructure to AWS.

It creates:

- VPC with public subnets (IPv4 only)
- Security Group with SSH access
- EIPs
- Network interfaces
- EC2 instances
- Route53 records

## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 1.4.0 |
| aws | ~> 5.0.1 |
| cloudinit | ~> 2.3.2 |
| random | ~> 3.5.1 |

## Providers

| Name | Version |
|------|---------|
| aws | 5.0.1 |
| cloudinit | 2.3.2 |
| random | 3.5.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| vpc | terraform-aws-modules/vpc/aws | ~> 4.0.2 |

## Resources

| Name | Type |
|------|------|
| [aws_ebs_volume.create](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_ebs_volume.create_prevent_destroy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_eip.ec2_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip_association.ec2_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_network_interface.ec2_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_route53_record.ec2_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_volume_attachment.attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_volume_attachment.create](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_volume_attachment.create_prevent_destroy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_vpc_security_group_egress_rule.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [random_id.instance_sg](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| default\_egress\_sg\_rules | Default security group egress rules. It could be included to the instances security group if `add_default_egress_sg_rules` is set to true." | ```map( object({ from_port = number to_port = number ip_protocol = string cidr_ipv4 = list(string) description = string }) )``` | ```{ "any_to_any": { "cidr_ipv4": [ "0.0.0.0/0" ], "description": "Any to Any", "from_port": 0, "ip_protocol": "-1", "to_port": 0 } }``` | no |
| default\_ingress\_sg\_rules | Default security group ingress rules.   It could be included to the instances security group if `add_default_ingress_sg_rules` is set to true. | ```map( object({ from_port = number to_port = number ip_protocol = string cidr_ipv4 = list(string) description = string }) )``` | `{}` | no |
| instances | Map of objects to describe instances.   Map key is used as a name for the instance and must be unique.   Project name will be used as a prefix for the instance name.   The `ami_id` accepts some pre-defined AMI names: `amzn2`, `al2023`, `ubuntu2204`.   The pre-defined AMI will always get the latest AMI ID for the selected region."   To add the default sg rules to the instance security group, set `add_default_egress_sg_rules` and/or `add_default_ingress_sg_rules` to `true`. | ```map(object({ ami_id = string instance_type = string key_name = optional(string, "") availability_zone = string disk_size = number additional_disks = optional( map( object({ size = number mount_point = string volume_id = optional(string, "") prevent_destroy = optional(bool, false) }) ), {}) add_default_egress_sg_rules = optional(bool, true) add_default_ingress_sg_rules = optional(bool, false) egress_sg_rules = optional( map( object({ from_port = number to_port = number ip_protocol = string cidr_ipv4 = list(string) description = string }) ), {}) ingress_sg_rules = optional( map( object({ from_port = number to_port = number ip_protocol = string cidr_ipv4 = list(string) description = string }) ), {}) tags = optional(map(string), {}) }))``` | n/a | yes |
| key\_name | Pre-existent key name created on the same region and AWS account that you are creating the resources. It should match `availabilty` zones. | `string` | n/a | yes |
| project | Project name. It will be used as a prefix for all resources. | `string` | n/a | yes |
| ssh | SSH configuration. | ```object({ port = number allowed_cidr_blocks = list(string) })``` | ```{ "allowed_cidr_blocks": [ "0.0.0.0/0" ], "port": 22 }``` | no |
| volume\_type | EBS Volume Type. | `string` | `"gp3"` | no |
| vpc | A object containing VPC information. AZs must be a letter that represents the AZ. For example: [\"a\", \"b\", \"c\"]. Number of public subnets must match the number of availability zones. Tags are applied to all resources for the VPC. | ```object({ cidr = string azs = list(string) public_subnets = list(string) public_subnet_tags = optional(map(string), {}) tags = optional(map(string), {}) })``` | n/a | yes |
| zone\_domain | A already hosted Route53 domain under the same AWS account that you are creating the resource. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| egress\_sg\_rules | It returns an object of egress security group rules. |
| ingress\_sg\_rules | It returns an object of ingress security group rules. |
| instances | It returns an object of all instances created by the module. |
| ssh | It returns an object of SSH connection details. |
