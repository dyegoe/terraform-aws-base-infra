terraform {
  required_version = "~> 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0.1"
    }
  }
}

locals {
  project = var.project
  region  = var.region
  default_tags = merge(
    {
      Project = local.project
    },
    var.default_tags
  )
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

module "aws_base_infra" {
  source = "../"

  project     = local.project
  key_name    = "default"              # This is a sample key, you should change it to your own key. It must be a key already created in AWS
  zone_domain = "this-is-a-sample.com" # This is a sample domain, you should change it to your own domain. It must be a domain hosted in Route53
  volume_type = "gp3"

  vpc = {
    cidr = "192.168.56.0/24"
    azs  = ["a", "b", "c"]
    public_subnets = [
      "192.168.56.0/26",
      "192.168.56.64/26",
      "192.168.56.128/26"
    ]
  }

  ssh = {
    port                = 22
    allowed_cidr_blocks = ["0.0.0.0/0"]
  }

  default_egress_sg_rules = {
    all_from_allowed = { from_port = -1, to_port = -1, ip_protocol = "-1", cidr_ipv4 = ["0.0.0.0/0"], description = "All traffic from allowed cidr - Default rules" }
  }
  default_ingress_sg_rules = {
    http = { from_port = 80, to_port = 80, ip_protocol = "tcp", cidr_ipv4 = ["0.0.0.0/0"], description = "HTTP Por - Default rules" }
  }

  instances = {
    sample-master01 = {
      ami_id            = data.aws_ssm_parameter.ami_id.value # This is an example how to use a SSM parameter to get the AMI ID
      instance_type     = "t3.nano"
      key_name          = "default" # This is a sample key, you should change it to your own key. It must be a key already created in AWS
      availability_zone = "a"       # The availability zone must be a letter (a, b, c, ...)
      disk_size         = 8
      additional_disks = {
        sdb = {
          size        = 1
          mount_point = "/mnt/sdb"
        }
        sdc = {
          size        = 1
          mount_point = "/mnt/sdc"
          # prevent_destroy = true # This is an example how to prevent the volume to be destroyed
        }
        # This an example how to add an existing volume to the instance
        # sdd = {
        #   size        = 1
        #   mount_point = "/srv"
        #   volume_id   = "vol-0c3eb3655dd853f3c"
        # }
      }
      add_default_egress_sg_rules  = false
      add_default_ingress_sg_rules = false
      egress_sg_rules = {
        any-to-any = { from_port = -1, to_port = -1, ip_protocol = "-1", cidr_ipv4 = ["0.0.0.0/0"], description = "Any to Any", }
      }
      ingress_sg_rules = {
        https = { from_port = 443, to_port = 443, ip_protocol = "tcp", cidr_ipv4 = ["0.0.0.0/0"], description = "HTTPS Port" }
      }
      tags = {
        Additional = "Tag"
      }
    }
    sample-node0001 = {
      ami_id                       = "amzn2" # This is an example how to use a pre-defined AMI name
      instance_type                = "t3.nano"
      availability_zone            = "a"
      disk_size                    = 8
      add_default_egress_sg_rules  = true # This is an example how to add the default egress sg rules to the instance security group
      add_default_ingress_sg_rules = true # This is an example how to add the default ingress sg rules to the instance security group
    }
    sample-node0002 = {
      ami_id                       = "ubuntu2204"
      instance_type                = "t3.nano"
      availability_zone            = "a"
      disk_size                    = 8
      add_default_ingress_sg_rules = true
    }
  }
}
