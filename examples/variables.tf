variable "region" {
  type        = string
  default     = "eu-north-1"
  description = "AWS region"
}

variable "project" {
  type        = string
  default     = "example-project"
  description = "Project name"
}

variable "default_tags" {
  type = map(string)
  default = {
    Owner       = "me"
    Environment = "dev"
    Terraform   = "true"
  }
  description = "Default tags"
}
