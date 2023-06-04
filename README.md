# AWS Base Infra Terraform module

This module itends to deploy some base infrasctructure to AWS.

It creates:

- [VPC](#vpc)
- [Security Groups](#security-groups)
- EIPs
- Network interfaces
- EC2 instances
- Route53 records

## Usage

```hcl
module "aws_base_infra" {
  source = "github.com/dyegoe/terraform-aws-base-infra?ref=main"

  project     = "example-project"
  key_name    = "default"
  zone_domain = "example.com"

  vpc = {
    cidr = "192.168.56.0/24"
    azs  = ["a", "b", "c"]
    public_subnets = [
      "192.168.56.0/26",
      "192.168.56.64/26",
      "192.168.56.128/26"
    ]
  }

  default_ingress_sg_rules = {
    internal = {
      from_port = -1,
      to_port = -1,
      ip_protocol = "-1",
      cidr_ipv4 = ["0.0.0.0/0"],
      description = "Allow any from anywhere"
    }
  }

  instances = {
    sample-node0001 = {
      ami_id            = "al2023"
      instance_type     = "t3.nano"
      availability_zone = "a"
      disk_size         = 8
    }
  }
}
```

## Components

All componentes names are prefixed with the project name (`var.project`). For example: `example-project-vpc`.

### VPC

It uses [terraform-aws-modules/vpc/aws](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/5.0.0) to create a VPC with the following characteristics:

- No IPV6 support.
- No NAT gateway.
- No public subnets.
- No public IP is mapped on launch.
- Full DNS support.
- CIDR block is defined by `var.vpc.cidr`.
- [AZs](#azs) are defined by `var.vpc.azs`.
- Public subnets (CIDRs) are defined by `var.vpc.public_subnets`.
- Additional tags to the VPC and public subnets using `var.vpc.tags` and `var.vpc.public_subnet_tags`

#### AZs

The AZs must be a letter that represents the AZ. For example: ["a", "b", "c"]. It will be concatenated with the ([aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)) region name to create the AZ name. The number of AZs must match the number of public subnets

### Security Groups

Each instace gets a security group. The security group name is the project name (`var.project`) concatenated with the instance name and a random string. For example: `example-project-sample-node0001-5f3a`. The random string is used to avoid security group name conflicts.

#### Ingress/Egress rules

The ingress/egress rules are defined by the following variables:

- `var.default_ingress_sg_rules`
- `var.default_egress_sg_rules`
- `var.instances.ingress_sg_rules`
- `var.instances.egress_sg_rules`
- `var.instances.add_default_ingress_sg_rules`
- `var.instances.add_default_egress_sg_rules`
- `var.ssh.allowed_cidr_blocks`
- `var.ssh.port`

##### Default ingress/egress rules

The default ingress/egress rules are applied to all instances security groups. It could be included to the instances security group if `var.instances.add_default_ingress_sg_rules` and/or `var.instances.add_default_egress_sg_rules` is set to `true`.

##### Instance ingress/egress rules

Additional ingress/egress rules can be provided to the instance security group using `var.instances.ingress_sg_rules` and `var.instances.egress_sg_rules`.

<!-- markdownlint-disable MD033 -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.4.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0.1 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | ~> 2.3.2 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.5.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0.1 |
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | ~> 2.3.2 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.5.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 4.0.2 |

## Resources

| Name | Type |
|------|------|
| [aws_ebs_volume.create](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_ebs_volume.create_prevent_destroy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_eip.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip_association.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_network_interface.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_route53_record.internal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.internal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_security_group.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_volume_attachment.attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_volume_attachment.create](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_volume_attachment.create_prevent_destroy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_vpc_security_group_egress_rule.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [random_id.instance_sg](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_default_tags.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route53_zone.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_ssm_parameter.al2023](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.amzn2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.ubuntu2204](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_subnet.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [cloudinit_config.instance](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_egress_sg_rules"></a> [default\_egress\_sg\_rules](#input\_default\_egress\_sg\_rules) | Default security group egress rules.<br>It could be included to the instances security group if `add_default_egress_sg_rules` is set to true." | <pre>map(<br>    object({<br>      from_port   = number<br>      to_port     = number<br>      ip_protocol = string<br>      cidr_ipv4   = list(string)<br>      description = string<br>    })<br>  )</pre> | <pre>{<br>  "default_any_to_any": {<br>    "cidr_ipv4": [<br>      "0.0.0.0/0"<br>    ],<br>    "description": "Any to Any",<br>    "from_port": -1,<br>    "ip_protocol": "-1",<br>    "to_port": -1<br>  }<br>}</pre> | no |
| <a name="input_default_ingress_sg_rules"></a> [default\_ingress\_sg\_rules](#input\_default\_ingress\_sg\_rules) | Default security group ingress rules.<br>  It could be included to the instances security group if `add_default_ingress_sg_rules` is set to true. | <pre>map(<br>    object({<br>      from_port   = number<br>      to_port     = number<br>      ip_protocol = string<br>      cidr_ipv4   = list(string)<br>      description = string<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_instances"></a> [instances](#input\_instances) | Map of objects to describe instances.<br>  Map key is used as a name for the instance and must be unique.<br>  Project name will be used as a prefix for the instance name.<br>  The `ami_id` accepts some pre-defined AMI names: `amzn2`, `al2023`, `ubuntu2204`.<br>  The pre-defined AMI will always get the latest AMI ID for the selected region."<br>  To add the default sg rules to the instance security group, set `add_default_egress_sg_rules` and/or `add_default_ingress_sg_rules` to `true`. | <pre>map(object({<br>    ami_id            = string<br>    instance_type     = string<br>    key_name          = optional(string, "")<br>    availability_zone = string<br>    disk_size         = number<br>    additional_disks = optional(<br>      map(<br>        object({<br>          size            = number<br>          mount_point     = string<br>          volume_id       = optional(string, "")<br>          prevent_destroy = optional(bool, false)<br>        })<br>    ), {})<br>    add_default_egress_sg_rules  = optional(bool, true)<br>    add_default_ingress_sg_rules = optional(bool, false)<br>    egress_sg_rules = optional(<br>      map(<br>        object({<br>          from_port   = number<br>          to_port     = number<br>          ip_protocol = string<br>          cidr_ipv4   = list(string)<br>          description = string<br>        })<br>    ), {})<br>    ingress_sg_rules = optional(<br>      map(<br>        object({<br>          from_port   = number<br>          to_port     = number<br>          ip_protocol = string<br>          cidr_ipv4   = list(string)<br>          description = string<br>        })<br>    ), {})<br>    tags = optional(map(string), {})<br>  }))</pre> | n/a | yes |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Pre-existent key name created on the same region and AWS account that you are creating the resources.<br>It should match `availabilty` zones. | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project name. It will be used as a prefix for all resources. | `string` | n/a | yes |
| <a name="input_ssh"></a> [ssh](#input\_ssh) | SSH configuration. | <pre>object({<br>    port                = number<br>    allowed_cidr_blocks = list(string)<br>  })</pre> | <pre>{<br>  "allowed_cidr_blocks": [<br>    "0.0.0.0/0"<br>  ],<br>  "port": 22<br>}</pre> | no |
| <a name="input_volume_type"></a> [volume\_type](#input\_volume\_type) | EBS Volume Type. | `string` | `"gp3"` | no |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | A object containing VPC information.<br>AZs must be a letter that represents the AZ.<br>For example: [\"a\", \"b\", \"c\"].<br>Number of public subnets must match the number of availability zones.<br>Tags are applied to all resources for the VPC. | <pre>object({<br>    cidr               = string<br>    azs                = list(string)<br>    public_subnets     = list(string)<br>    public_subnet_tags = optional(map(string), {})<br>    tags               = optional(map(string), {})<br>  })</pre> | n/a | yes |
| <a name="input_zone_domain"></a> [zone\_domain](#input\_zone\_domain) | A already hosted Route53 domain under the same AWS account that you are creating the resource. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_egress_sg_rules"></a> [egress\_sg\_rules](#output\_egress\_sg\_rules) | It returns an object of egress security group rules. |
| <a name="output_ingress_sg_rules"></a> [ingress\_sg\_rules](#output\_ingress\_sg\_rules) | It returns an object of ingress security group rules. |
| <a name="output_instances"></a> [instances](#output\_instances) | It returns an object of all instances created by the module. |
| <a name="output_ssh"></a> [ssh](#output\_ssh) | It returns an object of SSH connection details. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable MD033 -->

## Authors

Module is maintained by [Dyego Alexandre Eugenio](https://github.com/dyegoe)

## License

Apache 2 Licensed. See [LICENSE](https://github.com/dyegoe/terraform-aws-base-infra/tree/master/LICENSE) for full details.
