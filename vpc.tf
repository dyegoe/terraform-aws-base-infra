module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0.2"

  name                    = "${local.resource_name_prefix}-vpc"
  azs                     = local.azs
  cidr                    = var.vpc.cidr
  public_subnets          = var.vpc.public_subnets
  public_subnet_tags      = var.vpc.public_subnet_tags
  map_public_ip_on_launch = false
  enable_ipv6             = false
  enable_nat_gateway      = false
  enable_dns_hostnames    = true
  enable_dns_support      = true
  tags                    = var.vpc.tags
}
