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

## Providers

| Name | Version |
|------|---------|
| aws | 5.0.1 |
| cloudinit | 2.3.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| security\_group | terraform-aws-modules/security-group/aws | ~> 4.17.2 |
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
| [aws_volume_attachment.attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_volume_attachment.create](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_volume_attachment.create_prevent_destroy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ingress\_sg\_rules | A list of objects to describe ingress rules for the security group. The rules are applied to all instances. The rules are merged with the default rules. | ```list(object({ from_port = number to_port = number protocol = string description = string cidr_blocks = list(string) }))``` | `[]` | no |
| instances | Map of objects to describe instances. Map keys is used as a name for the instance and must be unique. The project name will be used as a prefix for the instance name. | ```map(object({ ami_id = string instance_type = string key_name = optional(string, "") availability_zone = string disk_size = number additional_disks = optional( map( object({ size = number mount_point = string volume_id = optional(string, "") prevent_destroy = optional(bool, false) }) ), {}) ingress_sg_rules = optional( list( object({ from_port = number to_port = number protocol = string description = string cidr_blocks = list(string) }) ), []) tags = map(string) }))``` | n/a | yes |
| key\_name | Pre-existent key name created on the same region and AWS account that you are creating the resources. It should match `availabilty` zones. | `string` | n/a | yes |
| project | Project name. It will be used as a prefix for all resources. | `string` | n/a | yes |
| ssh | SSH configuration. | ```object({ port = number allow_cidr_blocks = list(string) })``` | ```{ "allow_cidr_blocks": [ "0.0.0.0/0" ], "port": 22 }``` | no |
| volume\_type | EBS Volume Type. | `string` | `"gp3"` | no |
| vpc | A object containing VPC information. AZs must be a letter that represents the AZ. For example: ["a", "b", "c"]. Number of private/public subnets must match the number of availability zones. Tags are applied to all resources for the VPC. | ```object({ cidr = string azs = list(string) public_subnets = list(string) public_subnet_tags = optional(map(string), {}) tags = optional(map(string), {}) })``` | n/a | yes |
| zone\_domain | A already hosted Route53 domain under the same AWS account that you are creating the resource. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| instances | It returns an object of all instances created by the module. |
| ssh | n/a |
