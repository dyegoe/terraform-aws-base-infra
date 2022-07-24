variable "resource_name_prefix" {
  description = "Specify a name prefix for the resources"
  type        = string
  default     = "example-dev"
}

variable "availability_zones" {
  description = "A list of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.250.0.0/26"
}

variable "vpc_cidr_subnets_public" {
  description = "List of public subnets' CIDR"
  type        = list(string)
  default     = ["10.250.0.0/28", "10.250.0.16/28", "10.250.0.32/28"]
}

variable "key_name" {
  description = "Pre-existent key name created on the same region and AWS account that you are creating the resources. It should match `availabilty` zones."
  type        = string
}

variable "instances" {
  description = "Map of objects to describe instances."
  type = map(object({
    ami_id        = string
    instance_type = string
    disk_size     = number
    additional_disks = map(object({ # Let it empty if there aren't any additional disks
      size            = number
      mount_point     = string
      volume_id       = string
      prevent_destroy = bool
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
  description = "A already hosted Route53 domain under the same AWS account that you are creating the resource."
  type        = string
}

variable "ssh_port" {
  description = "SSH port number for the default SSH security group rule."
  type        = number
  default     = 22
}

variable "ssh_port_cidr_blocks" {
  description = "CIDR blocks to allow SSH access."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "volume_type" {
  description = "EBS Volume Type."
  type        = string
  default     = "gp2"
}

variable "cloud_init_user" {
  description = "User to add to the instances using cloud-init."
  type        = string
  default     = "ansible"
}

variable "cloud_init_public_key" {
  description = "Public key to add to the instances using cloud-init."
  type        = string
}
