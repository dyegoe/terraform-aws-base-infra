/*
 * # Terraform AWS Base Infra
 *
 * This is an example of how to use the module.
 *
 */

locals {
  region  = "eu-north-1"
  project = "aws-base-infra"
  default_tags = {
    Owner       = "me"
    Environment = "dev"
    Terraform   = "true"
    Project     = local.project
  }
}

provider "aws" {
  region = local.region
  default_tags {
    tags = local.default_tags
  }
}

data "aws_ssm_parameter" "ami_id" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

module "aws-base-infra" {
  source = "../"

  project     = local.project
  key_name    = "default"
  zone_domain = "aws.dyego.com.br"
  volume_type = "gp3"

  vpc = {
    cidr = "10.0.0.0/24"
    azs  = ["a", "b", "c"]
    public_subnets = [
      "10.0.0.0/26",
      "10.0.0.64/26",
      "10.0.0.128/26"
    ]
  }

  ssh = {
    port              = 22
    allow_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress_sg_rules = [
    { from_port = 443, to_port = 443, protocol = "tcp", description = "HTTPS Port", cidr_blocks = ["0.0.0.0/0"] }
  ]

  instances = {
    master = {
      ami_id            = data.aws_ssm_parameter.ami_id.value
      instance_type     = "t3.nano"
      availability_zone = "a"
      disk_size         = 8
      additional_disks = {
        "sdb" = {
          size        = 1
          mount_point = "/data"
        }
      }
      ingress_sg_rules = [
        { from_port = 80, to_port = 80, protocol = "tcp", description = "HTTP Port", cidr_blocks = ["0.0.0.0/0"] }
      ]
      tags = {
        Additional = "Tag"
      }
    }
    # node1 = {
    #   ami_id            = data.aws_ssm_parameter.ami_id.value
    #   instance_type     = "t3.nano"
    #   availability_zone = "a"
    #   disk_size         = 8
    #   additional_disks = {
    #     "sdb" = {
    #       size            = 1
    #       mount_point     = "/data"
    #       prevent_destroy = true
    #     }
    #     "sdd" = {
    #       size        = 1
    #       mount_point = "/srv"
    #       volume_id   = "vol-0c3eb3655dd853f3c"
    #     }
    #   }
    #   ingress_sg_rules = [
    #     { from_port = 80, to_port = 80, protocol = "tcp", description = "HTTP Port", cidr_blocks = ["0.0.0.0/0"] }
    #   ]
    #   tags = {
    #     Additional = "Tag"
    #   }
    # }
  }
}

output "instances" {
  value = module.aws-base-infra.instances
}
