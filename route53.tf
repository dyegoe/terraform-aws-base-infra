resource "aws_route53_record" "ec2_instance" {
  for_each = var.instances

  zone_id = data.aws_route53_zone.current.zone_id
  name    = "${each.key}.${local.resource_name_prefix}.${var.zone_domain}"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.ec2_instance[each.key].public_ip]

  depends_on = [
    module.vpc,
    aws_eip.ec2_instance,
  ]
}
