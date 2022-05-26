##### Security group module. NB! The CIDR here must be string separated by comma (,). join(",", list) #####
module "security_group" {
  for_each    = var.instances
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 4.9.0"
  name        = "${var.resource_name_prefix}-${each.key}"
  description = "Access related to ${var.resource_name_prefix}-${each.key}"
  vpc_id      = module.vpc.vpc_id
  tags        = { "Name" = "${var.resource_name_prefix}-${each.key}" }
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Any to Any"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  ingress_with_cidr_blocks = concat([
    {
      from_port   = var.ssh_port
      to_port     = var.ssh_port
      protocol    = "tcp"
      description = "SSH Port"
      cidr_blocks = join(",", var.ssh_port_cidr_blocks)
    }
  ], local.ingress_with_cidr_blocks[each.key])
}
