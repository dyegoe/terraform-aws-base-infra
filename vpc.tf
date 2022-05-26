module "vpc" {
  source                  = "terraform-aws-modules/vpc/aws"
  version                 = "~> 3.14.0"
  name                    = "${var.resource_name_prefix}-vpc"
  azs                     = var.availability_zones
  cidr                    = var.vpc_cidr
  public_subnets          = var.vpc_cidr_subnets_public
  map_public_ip_on_launch = false
  enable_ipv6             = false
  enable_nat_gateway      = false
  enable_dns_hostnames    = true
  enable_dns_support      = true
}
