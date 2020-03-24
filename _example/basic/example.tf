provider "aws" {
  region = "eu-west-1"
}

module "api-gateway" {
  source      = "../../"
  name        = "api-gateway"
  application = "clouddrove"
  environment = "test"
  label_order = ["environment", "name", "application"]
  enabled     = true

  # Api Gateway Resource
  path_parts = ["mytestresource", "mytestresource1"]

  # Api Gateway Method
  method_enabled = true
  http_methods   = ["GET", "GET"]

  # Api Gateway Integration
  integration_types        = ["MOCK", "AWS_PROXY"]
  integration_http_methods = ["POST", "POST"]
  uri                      = ["", "arn:aws:apigateway:eu-west-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-1:xxxxxxxxxxxx:function:test/invocations"]
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
}