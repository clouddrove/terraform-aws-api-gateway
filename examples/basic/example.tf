provider "aws" {
  region = "ca-central-1"
}

module "api_gateway" {
  source      = "../../"
  name        = "api-gateway"
  environment = "test"
}
