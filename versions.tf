# Terraform version
terraform {
  required_version = ">= 0.12.0, < 0.14.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}