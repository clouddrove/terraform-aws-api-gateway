# Terraform version
terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.80.0"
    }
  }

  provider_meta "aws" {
    user_agent = ["github.com/clouddrove/terraform-aws-api-gateway"]
  }
}
