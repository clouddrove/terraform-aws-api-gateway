provider "aws" {
  region = "eu-west-1"
}

module "api-gateway" {
  source      = "../../"
  name        = "api-gateway"
  repository  = "https://registry.terraform.io/modules/clouddrove/api-gateway/aws/0.14.0"
  environment = "test"
  label_order = ["name", "environment"]
  enabled     = true

  # Api Gateway Resource
  path_parts = ["mytestresource"]

  # Api Gateway Method
  method_enabled = true
  http_methods   = ["GET"]

  # Api Gateway Integration
  integration_types        = ["MOCK"]
  integration_http_methods = ["POST"]
  uri                      = [""]
  integration_request_parameters = [{
    "integration.request.header.X-Authorization" = "'static'"
  }]
  request_templates = [{
    "application/xml" = <<EOF
{
   "body" : $input.json('$')
}
EOF
  }]

  # Api Gateway Method Response
  status_codes        = [200]
  response_models     = [{ "application/json" = "Empty" }]
  response_parameters = [{ "method.response.header.X-Some-Header" = true }]

  # Api Gateway Integration Response
  integration_response_parameters = [{ "method.response.header.X-Some-Header" = "integration.response.header.X-Some-Other-Header" }]
  response_templates = [{
    "application/xml" = <<EOF
#set($inputRoot = $input.path('$'))
<?xml version="1.0" encoding="UTF-8"?>
<message>
    $inputRoot.body
</message>
EOF
  }]

  # Api Gateway Deployment
  deployment_enabled = true
  stage_name         = "deploy"

  # Api Gateway Stage
  stage_enabled = true
  stage_names   = ["qa"]
}
