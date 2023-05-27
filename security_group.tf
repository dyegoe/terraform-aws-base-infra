module "security_group" {
  for_each = var.instances

  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.17.2"

  name        = "${local.resource_name_prefix}-${each.key}"
  description = "Access related to ${local.resource_name_prefix}-${each.key} instance"
  vpc_id      = module.vpc.vpc_id

  egress_with_cidr_blocks = [
    { from_port = 0, to_port = 0, protocol = "-1", description = "Any to Any", cidr_blocks = "0.0.0.0/0" }
  ]
  ingress_with_cidr_blocks = concat([
    { from_port = var.ssh.port, to_port = var.ssh.port, protocol = "tcp", description = "SSH Port", cidr_blocks = join(",", var.ssh.allow_cidr_blocks) }
  ], local.ingress_sg_rules_instances[each.key], local.ingress_sg_rules)

  tags = {
    Name     = "${local.resource_name_prefix}-${each.key}"
    Instance = each.key
  }

  depends_on = [module.vpc]
}
