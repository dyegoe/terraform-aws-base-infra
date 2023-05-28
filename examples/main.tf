/*
 * # Terraform AWS Base Infra
 *
 * This is an example of how to use the module.
 *
 */

locals {
  region  = "eu-north-1"
  project = "example-project"
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
  zone_domain = "this-is-a-sample.com"
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
    port                = 22
    allowed_cidr_blocks = ["1.1.1.1/32"]
  }

  default_egress_sg_rules = {
    all_from_allowed = { from_port = -1, to_port = -1, ip_protocol = "-1", cidr_ipv4 = ["2.2.2.2/32"], description = "All traffic from allowed cidr - Default rules" }
  }
  default_ingress_sg_rules = {
    http = { from_port = 80, to_port = 80, ip_protocol = "tcp", cidr_ipv4 = ["3.3.3.3/32"], description = "HTTP Por - Default rules" }
  }

  instances = {
    sample-master01 = {
      ami_id            = data.aws_ssm_parameter.ami_id.value
      instance_type     = "t3.nano"
      key_name          = "default"
      availability_zone = "a"
      disk_size         = 8
      additional_disks = {
        sdb = {
          size        = 1
          mount_point = "/data"
        }
      }
      add_default_egress_sg_rules  = false
      add_default_ingress_sg_rules = false
      egress_sg_rules = {
        any-to-any = { from_port = -1, to_port = -1, ip_protocol = "-1", cidr_ipv4 = ["4.4.4.4/32"], description = "Any to Any", }
      }
      ingress_sg_rules = {
        http = { from_port = 80, to_port = 80, ip_protocol = "tcp", cidr_ipv4 = ["5.5.5.5/32"], description = "HTTP Port" }
      }
      tags = {
        Additional = "Tag"
      }
    }
    sample-node0001 = {
      ami_id            = "al2023"
      instance_type     = "t3.nano"
      key_name          = "default"
      availability_zone = "a"
      disk_size         = 8
      additional_disks = {
        sdb = {
          size            = 1
          mount_point     = "/data"
          prevent_destroy = true
        }
        # This an example how to add an existing volume to the instance
        # sdd = {
        #   size        = 1
        #   mount_point = "/srv"
        #   volume_id   = "vol-0c3eb3655dd853f3c"
        # }
      }
      add_default_egress_sg_rules  = true
      add_default_ingress_sg_rules = true
      egress_sg_rules              = {}
      ingress_sg_rules             = {}
      tags = {
        Additional2 = "Tag2"
      }
    }
  }
}

output "ssh" {
  value = module.aws-base-infra.ssh
}

output "instances" {
  value = module.aws-base-infra.instances
}

output "egress_sg_rules" {
  value = module.aws-base-infra.egress_sg_rules
}

output "ingress_sg_rules" {
  value = module.aws-base-infra.ingress_sg_rules
}
