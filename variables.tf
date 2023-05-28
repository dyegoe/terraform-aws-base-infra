##### Project
variable "project" {
  description = "Project name. It will be used as a prefix for all resources."
  type        = string

  validation {
    condition     = alltrue([var.project != null, var.project != ""])
    error_message = "The project name must be a non-empty string."
  }
}

##### Key Name
variable "key_name" {
  description = "Pre-existent key name created on the same region and AWS account that you are creating the resources. It should match `availabilty` zones."
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
  description = "A object containing VPC information. AZs must be a letter that represents the AZ. For example: [\"a\", \"b\", \"c\"]. Number of private/public subnets must match the number of availability zones. Tags are applied to all resources for the VPC."
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
variable "ssh" {
  description = "SSH configuration."
  type = object({
    port              = number
    allow_cidr_blocks = list(string)
  })
  default = {
    port              = 22
    allow_cidr_blocks = ["0.0.0.0/0"]
  }
}

##### Security Group Rules
variable "ingress_sg_rules" {
  description = "A list of objects to describe ingress rules for the security group. The rules are applied to all instances. The rules are merged with the default rules."
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
    cidr_blocks = list(string)
  }))
  default = []
}

##### Instances
variable "instances" {
  description = "Map of objects to describe instances. The Map key is used as a name for the instance and must be unique. The project name will be used as a prefix for the instance name. The `ami_id` accepts some pre-defined AMI names: amzn2, al2023, ubuntu2204. The pre-defined AMI will always get the latest AMI ID for the selected region."
  type = map(object({
    ami_id            = string
    instance_type     = string
    key_name          = optional(string, "")
    availability_zone = string
    disk_size         = number
    additional_disks = optional(
      map(
        object({
          size            = number
          mount_point     = string
          volume_id       = optional(string, "")
          prevent_destroy = optional(bool, false)
        })
    ), {})
    ingress_sg_rules = optional(
      list(
        object({
          from_port   = number
          to_port     = number
          protocol    = string
          description = string
          cidr_blocks = list(string)
        })
    ), [])
    tags = map(string)
  }))

  validation {
    condition     = alltrue([for instance, i in var.instances : can(regex("^(amzn2|al2023|ubuntu2204|ami-[a-z0-9]+)$", i.ami_id))])
    error_message = "The AMI ID must be a pre-defined AMI name or a valid AMI ID. Pre-defined AMI names: amzn2, al2023, ubuntu2204. Example of valid AMI ID: ami-0a887e401f7654935"
  }

  validation {
    condition     = alltrue([for instance, _ in var.instances : can(regex("^[a-z](?:[a-z0-9-]{0,30}[a-z0-9])?$", instance))])
    error_message = "The instance name must be a lowercase string with hyphens, numbers or letters. It must start with a letter and end with a letter or number."
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
