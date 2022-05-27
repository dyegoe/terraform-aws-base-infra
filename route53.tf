##### Create DNS record #####
resource "aws_route53_record" "this" {
  for_each = var.instances
  zone_id  = data.aws_route53_zone.this.zone_id
  name     = "${var.resource_name_prefix}-${each.key}.${var.zone_domain}"
  type     = "A"
  ttl      = "300"
  records  = [aws_eip.this[each.key].public_ip]
}
