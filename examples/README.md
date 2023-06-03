# Terraform AWS Base Infra

This is an example of how to use the module.

## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 1.4.0 |
| aws | ~> 5.0.1 |

## Providers

| Name | Version |
|------|---------|
| aws | 5.0.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| aws\_base\_infra | ../ | n/a |

## Resources

| Name | Type |
|------|------|

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| default\_tags | Default tags | `map(string)` | ```{ "Environment": "dev", "Owner": "me", "Terraform": "true" }``` | no |
| project | Project name | `string` | `"example-project"` | no |
| region | AWS region | `string` | `"eu-north-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| egress\_sg\_rules | Egress security group rules |
| ingress\_sg\_rules | Ingress security group rules |
| instances | Instances configuration |
| ssh | SSH configuration |
