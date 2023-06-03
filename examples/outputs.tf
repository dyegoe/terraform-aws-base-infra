output "ssh" {
  value       = module.aws_base_infra.ssh
  description = "SSH configuration"
}

output "instances" {
  value       = module.aws_base_infra.instances
  description = "Instances configuration"
}

output "egress_sg_rules" {
  value       = module.aws_base_infra.egress_sg_rules
  description = "Egress security group rules"
}

output "ingress_sg_rules" {
  value       = module.aws_base_infra.ingress_sg_rules
  description = "Ingress security group rules"
}
