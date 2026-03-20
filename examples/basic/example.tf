provider "aws" {
  region = "us-east-1"
}

module "api_gateway" {
  source      = "../../"
  name        = "api-gateway"
  environment = "test"
}
