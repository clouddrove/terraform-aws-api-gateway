# terraform-aws-api-gateway basic example

This is a basic example of the `terraform-aws-api-gateway` module.

## Usage

```hcl
module "api_gateway" {
  source      = "clouddrove/api-gateway/aws"
  name        = "api-gateway"
  environment = "test"
}
```
