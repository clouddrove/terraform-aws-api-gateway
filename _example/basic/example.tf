provider "aws" {
  region = "eu-west-1"
}

module "api-gateway" {
  source      = "../../"
  name        = "api-gateway"
  environment = "test"
  label_order = ["name", "environment"]
  enabled     = true

  # Api Gateway Resource
  path_parts = ["mytestresource"]

  ##endpoint_configuration
  types = ["PRIVATE"]

  # Api Gateway Method
  method_enabled = true
  http_methods   = ["GET"]

  # Api Gateway Integration
  cache_key_parameters = [""]
  integration_types        = ["MOCK"]
  integration_http_methods = []
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
  ## Api Policy

  api_policy = data.aws_iam_policy_document.test.json

}

data "aws_iam_policy_document" "test" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["execute-api:Invoke"]
    resources = [module.api-gateway.execution_arn]

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = ["123.123.123.123/32"]
    }
  }
}
