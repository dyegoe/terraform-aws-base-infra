variable "resource_name_prefix" {
  description = "Specify a name prefix for the resources"
  type        = string
}

variable "availability_zones" {
  description = "A list of availability zones"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "vpc_cidr_subnets_public" {
  description = "List of public subnets' CIDR"
  type        = list(string)
}

variable "key_name" {
  description = "Key name already created on AWS"
  type        = string
}

variable "instances" {
  description = "Map of objects to describe instances"
  type = map(object({
    ami_id        = string
    instance_type = string
    disk_size     = number
    additional_disks = map(object({ # Let it empty if there aren't any additional disks
      size        = number
      mount_point = string
      volume_id   = string
    }))
    tags              = map(string)
    availability_zone = string
    ingress_sg_rules = list(object({ # Let it empty if there aren't ingress rules
      from_port   = number
      to_port     = number
      protocol    = string
      description = string
      cidr_blocks = list(string)
    }))
  }))
}

variable "zone_domain" {
  description = "Domain on Route53"
  type        = string
}

variable "ssh_port" {
  description = "The SSH port number"
  type        = number
}

variable "ssh_port_cidr_blocks" {
  description = "CIDR blocks, list of strings"
  type        = list(string)
}

variable "volume_type" {
  description = "Volume Type"
  type        = string
  default     = "gp2"
}

variable "cloud_init_user" {
  description = "User to add to the instances using cloud-init"
  type        = string
  default     = "ansible"
}

variable "cloud_init_public_key" {
  description = "Public key to add to the instances using cloud-init"
  type        = string
}
