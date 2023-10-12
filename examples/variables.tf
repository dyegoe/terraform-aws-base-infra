variable "region" {
  type        = string
  default     = "eu-north-1"
  description = "AWS region"
}

variable "project" {
  type        = string
  default     = "example-project"
  description = "Project name to use for all resources"
}

variable "default_tags" {
  type = map(string)
  default = {
    Owner       = "me"
    Environment = "dev"
    Terraform   = "true"
  }
  description = "Default tags to apply to all resources"
}
