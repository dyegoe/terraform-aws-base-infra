output "instances" {
  value       = module.aws_base_infra.instances
  description = "Instances configuration"
}

output "shared_security_groups_id" {
  value       = module.aws_base_infra.shared_security_groups_id
  description = "Shared security groups id"
}

output "shared_security_group_egress_rules" {
  value       = module.aws_base_infra.shared_security_group_egress_rules
  description = "Egress security group rules"
}

output "shared_security_group_ingress_rules" {
  value       = module.aws_base_infra.shared_security_group_ingress_rules
  description = "Ingress security group rules"
}

output "instances_security_group_egress_rules" {
  value       = module.aws_base_infra.instances_security_group_egress_rules
  description = "Egress security group rules"
}

output "instances_security_group_ingress_rules" {
  value       = module.aws_base_infra.instances_security_group_ingress_rules
  description = "Ingress security group rules"
}
