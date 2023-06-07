##### Project
variable "project" {
  description = "Project name. It will be used as a prefix for all resources."
  type        = string

  validation {
    condition     = can(regex("^[a-z](?:[a-z0-9-]{0,13}[a-z0-9])?$", var.project))
    error_message = <<EOT
The project name must be a lowercase string with hyphens, numbers or letters.
It must start with a letter and end with a letter or number.
It must be between 1 and 15 characters long.
  EOT
  }
}

##### Key Name
variable "key_name" {
  description = <<EOT
Pre-existent key name created on the same region and AWS account that you are creating the resources.
It should match `availabilty` zones.
  EOT
  type        = string
}

##### Route53
variable "zone_domain" {
  description = "A already hosted Route53 domain under the same AWS account that you are creating the resource."
  type        = string
}

##### Volume Type
variable "volume_type" {
  description = "EBS Volume Type."
  type        = string
  default     = "gp3"
}

##### VPC
variable "vpc" {
  description = <<EOT
A object containing VPC information.
AZs must be a letter that represents the AZ.
For example: [\"a\", \"b\", \"c\"].
Number of public subnets must match the number of availability zones.
Tags are applied to all resources for the VPC.
  EOT
  type = object({
    cidr               = string
    azs                = list(string)
    public_subnets     = list(string)
    public_subnet_tags = optional(map(string), {})
    tags               = optional(map(string), {})
  })

  validation {
    condition     = alltrue([for az in var.vpc.azs : can(regex("^[a-z]$", az))])
    error_message = "The list of AZs must be a letter that represents the AZ. For example: [\"a\", \"b\", \"c\"]"
  }

  validation {
    condition     = length(var.vpc.azs) == length(var.vpc.public_subnets)
    error_message = "Number of private subnets must match the number of availability zones"
  }
}

##### SSH
variable "ssh_port" {
  description = "SSH port."
  type        = number
  default     = 22
}

##### Security Group Rules
variable "default_egress_sg_rules" {
  description = <<EOT
Default egress rules that could be added to instances security groups
when `add_default_egress_sg_rules` is set to true for each instance.
  EOT
  type = map(
    object({
      from_port   = number
      to_port     = number
      ip_protocol = string
      cidr_ipv4   = list(string)
      description = string
    })
  )
  default = {
    default_any_to_any = { from_port = -1, to_port = -1, ip_protocol = "-1", cidr_ipv4 = ["0.0.0.0/0"], description = "Any to Any" }
  }
}

variable "default_ingress_sg_rules" {
  description = <<EOT
Default ingress rules that could be added to instances security groups
when `add_default_ingress_sg_rules` is set to true for each instance.
  EOT
  type = map(
    object({
      from_port   = number
      to_port     = number
      ip_protocol = string
      cidr_ipv4   = list(string)
      description = string
    })
  )
  default = {}
}

variable "security_groups" {
  description = "Map of objects to describe security groups and its rules."
  type = map(object({
    description = string
    ingress = optional(map(object({
      from_port   = number
      to_port     = number
      ip_protocol = string
      cidr_ipv4   = optional(list(string))
      self        = optional(bool)
      description = string
    })))
    egress = optional(map(object({
      from_port   = number
      to_port     = number
      ip_protocol = string
      cidr_ipv4   = optional(list(string), null)
      self        = optional(bool, false)
      description = string
    })))
  }))

  validation {
    condition     = alltrue([for security_group, _ in var.security_groups : can(regex("^[a-z](?:[a-z0-9-]{0,13}[a-z0-9])?$", security_group))])
    error_message = <<EOT
The security group name must be a lowercase string with hyphens, numbers or letters.
It must start with a letter and end with a letter or number.
It must be between 1 and 15 characters long.
    EOT
  }
}

##### Instances
variable "instances" {
  description = <<EOT
Map of objects to describe instances.
Map key is used as a name for the instance and must be unique.
Project name will be used as a prefix for the instance name.
The `ami_id` accepts some pre-defined AMI names: `amzn2`, `al2023`, `ubuntu2204`.
The pre-defined AMI will always get the latest AMI ID for the selected region."
The `additional_disks` is a map of objects to describe additional disks to create/attach to the instance. The key must be a device name.
The `additional_security_groups` is a list of security groups to add to the instance. It must be a key from the `security_groups` variable.
To add the default sg rules to the instance security group, set `add_default_egress_sg_rules` and/or `add_default_ingress_sg_rules` to `true`.
  EOT
  type = map(object({
    ami_id            = string
    instance_type     = string
    key_name          = optional(string, "")
    availability_zone = string
    disk_size         = optional(number, 8)
    additional_disks = optional(map(object({
      size            = number
      mount_point     = string
      volume_id       = optional(string, "")
      prevent_destroy = optional(bool, false)
    })), {})
    additional_security_groups   = optional(list(string), [])
    add_default_egress_sg_rules  = optional(bool, false)
    add_default_ingress_sg_rules = optional(bool, false)
    egress_sg_rules = optional(map(object({
      from_port   = number
      to_port     = number
      ip_protocol = string
      cidr_ipv4   = list(string)
      description = string
    })), {})
    ingress_sg_rules = optional(map(object({
      from_port   = number
      to_port     = number
      ip_protocol = string
      cidr_ipv4   = list(string)
      description = string
    })), {})
    tags = optional(map(string), {})
  }))

  validation {
    condition     = alltrue([for instance, i in var.instances : can(regex("^(amzn2|al2023|ubuntu2204|ami-[a-z0-9]+)$", i.ami_id))])
    error_message = <<EOT
The AMI ID must be a pre-defined AMI name or a valid AMI ID.
Pre-defined AMI names: amzn2, al2023, ubuntu2204.
Example of valid AMI ID: ami-0a887e401f7654935"
    EOT
  }

  validation {
    condition     = alltrue([for instance, _ in var.instances : can(regex("^[a-z](?:[a-z0-9-]{0,13}[a-z0-9])?$", instance))])
    error_message = <<EOT
The instance name must be a lowercase string with hyphens, numbers or letters.
It must start with a letter and end with a letter or number.
It must be between 1 and 15 characters long.
    EOT
  }

  validation {
    condition     = alltrue([for instance, i in var.instances : can(regex("^[a-z]$", i.availability_zone))])
    error_message = "The availability zone must be a letter that represents the AZ. For example: \"a\""
  }

  validation {
    condition = alltrue(flatten([
      for instance, i in var.instances : [
        for disk, d in i.additional_disks : can(regex("^[a-z]{3}[a-z0-9]?$", disk))
      ]
    ]))
    error_message = "Device consists of three lowercase letters followed by an optional lowercase letter or digit at the end."
  }
}
