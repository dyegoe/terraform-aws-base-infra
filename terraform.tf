terraform {
  required_version = "~> 1.2.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.9.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.1.3"
    }
  }
}
