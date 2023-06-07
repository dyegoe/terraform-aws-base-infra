# AWS Base Infra Terraform module

This module itends to deploy some base infrasctructure to AWS.

- [AWS Base Infra Terraform module](#aws-base-infra-terraform-module)
  - [Usage](#usage)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
  - [Resources](#resources)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
  - [Components](#components)
    - [VPC](#vpc)
      - [AZs](#azs)
    - [Security Groups](#security-groups)
      - [Shared security groups](#shared-security-groups)
      - [Instances egress/ingress rules](#instances-egressingress-rules)
    - [Network Interfaces](#network-interfaces)
    - [EIPs](#eips)
    - [Route53](#route53)
    - [EBS Volumes](#ebs-volumes)
    - [EC2 instances](#ec2-instances)
      - [Instance parameters](#instance-parameters)
    - [Cloud-init](#cloud-init)
  - [Examples](#examples)
  - [Authors](#authors)
  - [License](#license)

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
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 5.0.0 |

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
| [aws_security_group.shared](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_volume_attachment.attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_volume_attachment.create](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_volume_attachment.create_prevent_destroy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_vpc_security_group_egress_rule.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.shared](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.shared](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [random_id.instance_sg](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_id.shared_sg](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
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
| <a name="input_default_egress_sg_rules"></a> [default\_egress\_sg\_rules](#input\_default\_egress\_sg\_rules) | Default egress rules that could be added to instances security groups<br>when `add_default_egress_sg_rules` is set to true for each instance. | <pre>map(<br>    object({<br>      from_port   = number<br>      to_port     = number<br>      ip_protocol = string<br>      cidr_ipv4   = list(string)<br>      description = string<br>    })<br>  )</pre> | <pre>{<br>  "default_any_to_any": {<br>    "cidr_ipv4": [<br>      "0.0.0.0/0"<br>    ],<br>    "description": "Any to Any",<br>    "from_port": -1,<br>    "ip_protocol": "-1",<br>    "to_port": -1<br>  }<br>}</pre> | no |
| <a name="input_default_ingress_sg_rules"></a> [default\_ingress\_sg\_rules](#input\_default\_ingress\_sg\_rules) | Default ingress rules that could be added to instances security groups<br>when `add_default_ingress_sg_rules` is set to true for each instance. | <pre>map(<br>    object({<br>      from_port   = number<br>      to_port     = number<br>      ip_protocol = string<br>      cidr_ipv4   = list(string)<br>      description = string<br>    })<br>  )</pre> | `{}` | no |
| <a name="input_instances"></a> [instances](#input\_instances) | Map of objects to describe instances.<br>Map key is used as a name for the instance and must be unique.<br>Project name will be used as a prefix for the instance name.<br>The `ami_id` accepts some pre-defined AMI names: `amzn2`, `al2023`, `ubuntu2204`.<br>The pre-defined AMI will always get the latest AMI ID for the selected region."<br>The `additional_disks` is a map of objects to describe additional disks to create/attach to the instance. The key must be a device name.<br>The `additional_security_groups` is a list of security groups to add to the instance. It must be a key from the `security_groups` variable.<br>To add the default sg rules to the instance security group, set `add_default_egress_sg_rules` and/or `add_default_ingress_sg_rules` to `true`. | <pre>map(object({<br>    ami_id            = string<br>    instance_type     = string<br>    key_name          = optional(string, "")<br>    availability_zone = string<br>    disk_size         = optional(number, 8)<br>    additional_disks = optional(map(object({<br>      size            = number<br>      mount_point     = string<br>      volume_id       = optional(string, "")<br>      prevent_destroy = optional(bool, false)<br>    })), {})<br>    additional_security_groups   = optional(list(string), [])<br>    add_default_egress_sg_rules  = optional(bool, false)<br>    add_default_ingress_sg_rules = optional(bool, false)<br>    egress_sg_rules = optional(map(object({<br>      from_port   = number<br>      to_port     = number<br>      ip_protocol = string<br>      cidr_ipv4   = list(string)<br>      description = string<br>    })), {})<br>    ingress_sg_rules = optional(map(object({<br>      from_port   = number<br>      to_port     = number<br>      ip_protocol = string<br>      cidr_ipv4   = list(string)<br>      description = string<br>    })), {})<br>    tags = optional(map(string), {})<br>  }))</pre> | n/a | yes |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Pre-existent key name created on the same region and AWS account that you are creating the resources.<br>It should match `availabilty` zones. | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project name. It will be used as a prefix for all resources. | `string` | n/a | yes |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | Map of objects to describe security groups and its rules. | <pre>map(object({<br>    description = string<br>    ingress = optional(map(object({<br>      from_port   = number<br>      to_port     = number<br>      ip_protocol = string<br>      cidr_ipv4   = optional(list(string))<br>      self        = optional(bool)<br>      description = string<br>    })))<br>    egress = optional(map(object({<br>      from_port   = number<br>      to_port     = number<br>      ip_protocol = string<br>      cidr_ipv4   = optional(list(string), null)<br>      self        = optional(bool, false)<br>      description = string<br>    })))<br>  }))</pre> | n/a | yes |
| <a name="input_ssh_port"></a> [ssh\_port](#input\_ssh\_port) | SSH port. | `number` | `22` | no |
| <a name="input_volume_type"></a> [volume\_type](#input\_volume\_type) | EBS Volume Type. | `string` | `"gp3"` | no |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | A object containing VPC information.<br>AZs must be a letter that represents the AZ.<br>For example: [\"a\", \"b\", \"c\"].<br>Number of public subnets must match the number of availability zones.<br>Tags are applied to all resources for the VPC. | <pre>object({<br>    cidr               = string<br>    azs                = list(string)<br>    public_subnets     = list(string)<br>    public_subnet_tags = optional(map(string), {})<br>    tags               = optional(map(string), {})<br>  })</pre> | n/a | yes |
| <a name="input_zone_domain"></a> [zone\_domain](#input\_zone\_domain) | A already hosted Route53 domain under the same AWS account that you are creating the resource. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instances"></a> [instances](#output\_instances) | It returns an object of all instances created by the module. |
| <a name="output_instances_security_group_egress_rules"></a> [instances\_security\_group\_egress\_rules](#output\_instances\_security\_group\_egress\_rules) | It returns an object of instances security group egress rules. |
| <a name="output_instances_security_group_ingress_rules"></a> [instances\_security\_group\_ingress\_rules](#output\_instances\_security\_group\_ingress\_rules) | It returns an object of instances security group ingress rules. |
| <a name="output_shared_security_group_egress_rules"></a> [shared\_security\_group\_egress\_rules](#output\_shared\_security\_group\_egress\_rules) | It returns an object of shared security group egress rules. |
| <a name="output_shared_security_group_ingress_rules"></a> [shared\_security\_group\_ingress\_rules](#output\_shared\_security\_group\_ingress\_rules) | It returns an object of shared security group ingress rules. |
| <a name="output_shared_security_groups_id"></a> [shared\_security\_groups\_id](#output\_shared\_security\_groups\_id) | It returns an object of shared security groups id. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable MD033 -->

## Components

All componentes names are prefixed with the [project name](#input_project). For example: `example-project-vpc`.

### VPC

It uses [terraform-aws-modules/vpc/aws](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/5.0.0) to create a VPC with the following characteristics:

- No IPV6 support.
- No NAT gateway.
- No public subnets.
- No public IP is mapped on launch.
- Full DNS support.
- CIDR block is defined by [VPC CIDR](#input_vpc).
- [AZs](#azs) are defined by [VPC AZs](#input_vpc).
- Public subnets (CIDRs) are defined by [VPC public subnets](#input_vpc).
- Additional tags to the VPC and public subnets using [VPC tags](#input_vpc) and [VPC public subnet tags](#input_vpc).

#### AZs

The AZs must be a letter that represents the AZ. For example: ["a", "b", "c"]. It will be concatenated with the ([aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)) region name to create the AZ name. The number of AZs must match the number of public subnets

### Security Groups

#### Shared security groups

Shared security groups are created iterating over the [security group](#input_security_groups) variable. The security group name is the [project name](#input_project) concatenated with the security group name. For example: `example-project-sample-sg`.

The map keys are the security group names and must be unique. Each security group has two lists: egress/ingress rules.

The egress/ingress rules are defined by the following syntax:

```hcl
{
  from_port   = number
  to_port     = number
  ip_protocol = string
  cidr_ipv4   = optional(list(string), null)
  self        = optional(bool, false)
  description = string
}
```

- The `cidr_ipv4` and `self` are optional.
- If `self` is set to `true` the security group id will be used as source or destination. Then `cidr_ipv4` is not required and will be ignored.
- If `self` is set to `false` the `cidr_ipv4` is required and the security group id will be ignored.

#### Instances egress/ingress rules

Each instace gets a security group. The security group name is the [project name](#input_project) concatenated with the instance name and a random string. For example: `example-project-sample-node0001-5f3a`. The random string is used to avoid security group name conflicts.

The egress/ingress rules are defined by the following variables:

- `var.default_egress_sg_rules`
- `var.default_ingress_sg_rules`
- `var.instances.egress_sg_rules`
- `var.instances.ingress_sg_rules`
- `var.instances.add_default_ingress_sg_rules`
- `var.instances.add_default_egress_sg_rules`

Security group rules have the following syntax:

```hcl
{
  from_port   = number
  to_port     = number
  ip_protocol = string
  cidr_ipv4   = list(string)
  description = string
}
```

The default egress/ingress rules could be included to the instances security group if `var.instances.add_default_ingress_sg_rules` and/or `var.instances.add_default_egress_sg_rules` is/are set to `true`.

### Network Interfaces

Because of a limitation of the [aws_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) resource, the network interfaces don't get tags. The workaround is to use the [aws_network_interface](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) resource to create the network interfaces and then attach them to the instances. The network interface name is the [project name](#input_project) concatenated with the instance name. For example: `example-project-sample-node0001`.

### EIPs

Each instance gets an EIP. The EIP name is the [project name](#input_project) concatenated with the instance name. For example: `example-project-sample-node0001`.

### Route53

This componente expects a hosted zone under the same AWS account that you are creating the resource. The hosted zone name must match the [zone domain](#input_zone_domain). For example: `example.com`.

Additionaly, the [project name](#input_project) is used as subdomain. For example: `example-project.example.com`.

A internal zone ([aws_route53_record.internal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)) is created following the same subdomain pattern (`example-project.example.com`) and it is attached to the [VPC](#vpc).

By design, two records are created for each instance:

- `sample-node0001.example-project.example.com` on the public zone ([aws_route53_record.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)) pointing to the [EIP](#eips).
- `sample-node0001.example-project.example.com` on the internal zone ([aws_route53_record.internal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)) pointing to the [network interface](#network-interfaces) private ip.

### EBS Volumes

Each instance gets a root EBS volume when creating the instance. However, additional EBS volumes can be created and attached to the instance using the [additional disks](#input_instances) variable.

```hcl
variable "instances" {
  ...
    additional_disks = optional(map(object({
      size            = number
      mount_point     = string
      volume_id       = optional(string, "")
      prevent_destroy = optional(bool, false)
    })), {})
  ...
}
```

The variable above is iterated in different local variables to create the EBS volumes and attach them to the instance.

- `local.additional_disks_to_create_prevent_destroy` is a map of objects to create the EBS volumes with the `prevent_destroy` attribute set to `true` and `volume_id` is not provided.
- `local.additional_disks_to_create` is a map of objects to create the EBS volumes with the `prevent_destroy` attribute set to `false` and `volume_id` is not provided.
- `local.additional_disks_to_attach` is a map of objects to attach the EBS volumes to the instance. It attaches all volumes created by `local.additional_disks_to_create_prevent_destroy` and `local.additional_disks_to_create` and also the volumes that already exists (`volume_id` is provided).

**NB**: The `prevent_destroy` attribute is used to avoid destroying the EBS volume when running `terraform destroy`.

You must remove the resource manually:

```bash
terraform state list
terraform state show 'module.aws_base_infra.aws_ebs_volume.create["sample-master01_sdb"]'
terraform state rm 'module.aws_base_infra.aws_ebs_volume.create["sample-master01_sdb"]'
terraform destroy
```

Then, you can use this EBS volume later by providing the `volume_id` attribute that matches `id` from the `terraform state show` command above.

```hcl
variable "instances" {
  ...
    additional_disks = {
      sdb = {
        size            = 8
        mount_point     = "/data"
        volume_id       = "vol-0a1b2c3d4e5f6g7h8"
      }
    }
  ...
}
```

### EC2 instances

The resource [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) is used to create the instances. The instance name is the [project name](#input_project) concatenated with the instance name. For example: `example-project-sample-node0001`.

The resource iterates the map of objects provided by the [instances](#input_instances) variable to create the instances. Each map key represents the instance name and must be unique.

```hcl
{
  ami_id            = string
  instance_type     = string
  key_name          = optional(string, "")
  availability_zone = string
  disk_size         = optional(number, 8)
  additional_disks = optional(map(object({
    size            = number
    mount_point     = string
    volume_id       = optional(string, "")
    prevent_destroy = optional(bool, false)
  })), {})
  add_default_egress_sg_rules  = optional(bool, true)
  add_default_ingress_sg_rules = optional(bool, false)
  egress_sg_rules = optional(map(object({
    from_port   = number
    to_port     = number
    ip_protocol = string
    cidr_ipv4   = list(string)
    description = string
  })), {})
  ingress_sg_rules = optional(map(object({
    from_port   = number
    to_port     = number
    ip_protocol = string
    cidr_ipv4   = list(string)
    description = string
  })), {})
  tags = optional(map(string), {})
}
```

#### Instance parameters

- `ami_id` accepts some pre-defined AMI names: `amzn2`, `al2023`, `ubuntu2204`. The pre-defined AMI will always get the latest AMI ID for the selected region.
- `key_name` is the name of a pre-existent key created on the same region and AWS account that you are creating the resources. If not provided here, it uses the [key_name](#input_key_name) variable.
- `availability_zone` must be a letter that represents the AZ. For example: "a". It will be concatenated with the ([aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)) region name to create the AZ name.
- `disk_size` is the root EBS volume size in GB. Default is 8.
- `additional_disks` is a map of objects to describe additional disks to create/attach to the instance. The key must be a device name. See [EBS Volumes](#ebs-volumes) for more details.
- `additional_security_groups` is a list of additional security groups to attach to the instance. It must be a key from the `security_groups` map. See [Security Groups](#security-groups) for more details.
- `add_default_egress_sg_rules` and `add_default_ingress_sg_rules` are used to add the default sg rules to the instance security group. Default is `true` for `add_default_egress_sg_rules` and `false` for `add_default_ingress_sg_rules`.
- `egress_sg_rules` and `ingress_sg_rules` are used to add additional sg rules to the instance security group. See [Security Groups](#security-groups) for more details.

### Cloud-init

The [cloudinit_config.instance](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) data source is used to create the cloud-init configuration. The cloud-init configuration is used to:

- Change the SSH port.
- Disable SELinux.
- Change hostname.
- Set search domain.

## Examples

You can find an example [here](examples/) of how to use this module.

## Authors

Module is maintained by [Dyego Alexandre Eugenio](https://github.com/dyegoe)

## License

Apache 2 Licensed. See [LICENSE](https://github.com/dyegoe/terraform-aws-base-infra/tree/master/LICENSE) for full details.
