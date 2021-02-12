provider "aws" {
  region = "eu-west-1"
}

module "api-gateway" {
  source = "../../"

  name        = "api-gateway"
  repository  = "https://registry.terraform.io/modules/clouddrove/api-gateway/aws/0.14.0"
  environment = "test"
  label_order = ["name", "environment"]
  enabled     = true

  # Api Gateway Resource
  path_parts = ["mytestresource", "mytestresource1"]

  # Api Gateway Method
  method_enabled = true
  http_methods   = ["GET", "GET"]

  # Api Gateway Integration
  integration_types        = ["MOCK", "AWS_PROXY"]
  integration_http_methods = ["POST", "POST"]
  uri                      = ["", "arn:aws:apigateway:eu-west-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-1:xxxxxxxxxx:function:test/invocations"]
  integration_request_parameters = [{
    "integration.request.header.X-Authorization" = "'static'"
  }, {}]
  request_templates = [{
    "application/xml" = <<EOF
{
   "body" : $input.json('$')
}
EOF
  }, {}]

  # Api Gateway Method Response
  status_codes        = [200, 200]
  response_models     = [{ "application/json" = "Empty" }, {}]
  response_parameters = [{ "method.response.header.X-Some-Header" = true }, {}]

  # Api Gateway Integration Response
  integration_response_parameters = [{ "method.response.header.X-Some-Header" = "integration.response.header.X-Some-Other-Header" }, {}]
  response_templates = [{
    "application/xml" = <<EOF
#set($inputRoot = $input.path('$'))
<?xml version="1.0" encoding="UTF-8"?>
<message>
    $inputRoot.body
</message>
EOF
  }, {}]

  # Api Gateway Deployment
  deployment_enabled = true
  stage_name         = "deploy"

  # Api Gateway Stage
  stage_enabled = true
  stage_names   = ["qa", "dev"]

  # Api Gateway Client Certificate
  cert_enabled     = true
  cert_description = "clouddrove"

  # Api Gateway Authorizer
  authorizer_count                = 2
  authorizer_names                = ["test", "test1"]
  authorizer_uri                  = ["arn:aws:apigateway:eu-west-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-1:xxxxxxxxxx:function:test/invocations", "arn:aws:apigateway:eu-west-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-1:xxxxxxxxxx:function:test/invocations"]
  authorizer_credentials          = ["arn:aws:iam::xxxxxxxxxx:role/lambda-role", "arn:aws:iam::xxxxxxxxxx:role/lambda-role"]
  identity_sources                = ["method.request.header.Authorization", "method.request.header.Authorization"]
  identity_validation_expressions = ["sfdgfhghrfdsdas", ""]
  authorizer_types                = ["TOKEN", "REQUEST"]

  # Api Gateway Gateway Response
  gateway_response_count = 2
  response_types         = ["UNAUTHORIZED", "RESOURCE_NOT_FOUND"]
  gateway_status_codes   = ["401", "404"]

  # Api Gateway Model
  model_count   = 2
  model_names   = ["test", "test1"]
  content_types = ["application/json", "application/json"]

  # Api Gateway Api Key
  key_count = 2
  key_names = ["test", "test1"]
}
