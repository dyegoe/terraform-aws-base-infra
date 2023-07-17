resource "aws_route53_record" "public" {
  for_each = {
    for instance, i in aws_eip.instance : instance => {
      public_ip = i.public_ip
    }
  }

  zone_id = data.aws_route53_zone.current.zone_id
  name    = "${each.key}.${local.zone_domain}"
  type    = "A"
  ttl     = "300"
  records = [each.value.public_ip]

  depends_on = [
    module.vpc,
    aws_eip.instance,
  ]
}

resource "aws_route53_zone" "internal" {
  name = local.zone_domain

  vpc {
    vpc_id     = module.vpc.vpc_id
    vpc_region = data.aws_region.current.name
  }

  tags = {
    Name = local.zone_domain
    Zone = "internal"
  }

  depends_on = [module.vpc]
}

resource "aws_route53_record" "internal" {
  for_each = var.instances

  zone_id = aws_route53_zone.internal.zone_id
  name    = "${each.key}.${local.zone_domain}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.this[each.key].private_ip]

  depends_on = [
    module.vpc,
    aws_instance.this,
  ]
}
