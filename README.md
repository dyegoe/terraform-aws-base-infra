<!-- BEGIN_TF_DOCS -->
# Terraform AWS Base Infra

This module itends to deploy some base infrasctructure to AWS.

## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 1.2.3 |
| aws | ~> 4.9.0 |
| random | ~>3.1.3 |
| template | ~> 2.2.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 4.9.0 |
| template | ~> 2.2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| security\_group | terraform-aws-modules/security-group/aws | ~> 4.9.0 |
| vpc | terraform-aws-modules/vpc/aws | ~> 3.14.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ebs_volume.create](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_ebs_volume.create_prevent_destroy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip_association.eip_assoc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_iam_instance_profile.ec2_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.ec2_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.ec2_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ec2_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_route53_record.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_volume_attachment.attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_volume_attachment.create](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| availability\_zones | A list of availability zones | `list(string)` | ```[ "us-east-1a", "us-east-1b", "us-east-1c" ]``` | no |
| cloud\_init\_public\_key | Public key to add to the instances using cloud-init. | `string` | n/a | yes |
| cloud\_init\_user | User to add to the instances using cloud-init. | `string` | `"ansible"` | no |
| instances | Map of objects to describe instances. | ```map(object({ ami_id = string instance_type = string disk_size = number additional_disks = map(object({ # Let it empty if there aren't any additional disks size = number mount_point = string volume_id = string prevent_destroy = bool })) tags = map(string) availability_zone = string ingress_sg_rules = list(object({ # Let it empty if there aren't ingress rules from_port = number to_port = number protocol = string description = string cidr_blocks = list(string) })) }))``` | n/a | yes |
| key\_name | Pre-existent key name created on the same region and AWS account that you are creating the resources. It should match `availabilty` zones. | `string` | n/a | yes |
| resource\_name\_prefix | Specify a name prefix for the resources | `string` | `"example-dev"` | no |
| ssh\_port | SSH port number for the default SSH security group rule. | `number` | `22` | no |
| ssh\_port\_cidr\_blocks | CIDR blocks to allow SSH access. | `list(string)` | ```[ "0.0.0.0/0" ]``` | no |
| volume\_type | EBS Volume Type. | `string` | `"gp2"` | no |
| vpc\_cidr | VPC CIDR | `string` | `"10.250.0.0/26"` | no |
| vpc\_cidr\_subnets\_public | List of public subnets' CIDR | `list(string)` | ```[ "10.250.0.0/28", "10.250.0.16/28", "10.250.0.32/28" ]``` | no |
| zone\_domain | A already hosted Route53 domain under the same AWS account that you are creating the resource. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| instances | It returns an object of all instances created by the module. |

<!-- END_TF_DOCS -->