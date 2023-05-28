##### Random ID for instances security group name
resource "random_id" "instance_sg" {
  for_each = var.instances

  keepers = {
    default_egress_sg_rules      = jsonencode(var.default_egress_sg_rules)
    default_ingress_sg_rules     = jsonencode(var.default_ingress_sg_rules)
    add_default_egress_sg_rules  = each.value.add_default_egress_sg_rules
    add_default_ingress_sg_rules = each.value.add_default_ingress_sg_rules
    egress_sg_rules              = jsonencode(each.value.egress_sg_rules)
    ingress_sg_rules             = jsonencode(each.value.ingress_sg_rules)
  }
  byte_length = 32
}
