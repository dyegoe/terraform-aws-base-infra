# AWS Base Infra Terraform module - usage example

This is an example of how to use the module.

<!-- markdownlint-disable MD033 -->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.19.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.19.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_base_infra"></a> [aws\_base\_infra](#module\_aws\_base\_infra) | ../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.ami_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Default tags to apply to all resources | `map(string)` | <pre>{<br>  "Environment": "dev",<br>  "Owner": "me",<br>  "Terraform": "true"<br>}</pre> | no |
| <a name="input_project"></a> [project](#input\_project) | Project name to use for all resources | `string` | `"example-project"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"eu-north-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instances"></a> [instances](#output\_instances) | Instances configuration |
| <a name="output_instances_security_group_egress_rules"></a> [instances\_security\_group\_egress\_rules](#output\_instances\_security\_group\_egress\_rules) | Egress security group rules |
| <a name="output_instances_security_group_ingress_rules"></a> [instances\_security\_group\_ingress\_rules](#output\_instances\_security\_group\_ingress\_rules) | Ingress security group rules |
| <a name="output_shared_security_group_egress_rules"></a> [shared\_security\_group\_egress\_rules](#output\_shared\_security\_group\_egress\_rules) | Egress security group rules |
| <a name="output_shared_security_group_ingress_rules"></a> [shared\_security\_group\_ingress\_rules](#output\_shared\_security\_group\_ingress\_rules) | Ingress security group rules |
| <a name="output_shared_security_groups_id"></a> [shared\_security\_groups\_id](#output\_shared\_security\_groups\_id) | Shared security groups id |
<!-- END_TF_DOCS -->
<!-- markdownlint-enable MD033 -->

## Authors

Module is maintained by [Dyego Alexandre Eugenio](https://github.com/dyegoe)
