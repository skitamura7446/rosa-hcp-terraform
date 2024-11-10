terraform {
  required_providers {
    rhcs = {
      source = "terraform-redhat/rhcs"
    }
  }
}

provider "aws" {
}

provider "rhcs" {
  token = var.ROSA_TOKEN 
}

variable "ROSA_TOKEN" {
  type        = string
  description = "Token for accessing ROSA API"
  sensitive   = true
}
