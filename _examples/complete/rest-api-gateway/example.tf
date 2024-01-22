####----------------------------------------------------------------------------------
## Provider block added, Use the Amazon Web Services (AWS) provider to interact with the many resources supported by AWS.
####----------------------------------------------------------------------------------
provider "aws" {
  region = local.region
}

locals {
  name        = "api"
  environment = "test"
  domain_name = "clouddrove.ca"
  region      = "us-east-1"
}
####----------------------------------------------------------------------------------
## This terraform module is designed to generate consistent label names and tags for resources.
####----------------------------------------------------------------------------------
module "acm" {
  source  = "clouddrove/acm/aws"
  version = "1.4.1"

  name                      = local.name
  environment               = local.environment
  enable_aws_certificate    = true
  domain_name               = local.domain_name
  subject_alternative_names = ["*.${local.domain_name}"]
  validation_method         = "DNS"
  enable_dns_validation     = false
}

####----------------------------------------------------------------------------------
## This terraform module is designed to generate consistent label names and tags for resources.
####----------------------------------------------------------------------------------
module "lambda" {
  source  = "clouddrove/lambda/aws"
  version = "1.3.1"

  name        = local.name
  environment = local.environment
  enable      = true
  timeout     = 60
  filename    = "../lambda_packages/index.zip"
  handler     = "index.lambda_handler"
  runtime     = "python3.8"
  iam_actions = [
    "logs:CreateLogStream",
    "logs:CreateLogGroup",
    "logs:PutLogEvents"
  ]
  names = [
    "python_layer"
  ]
  compatible_runtimes = [
    ["python3.8"]
  ]
  statement_ids = [
    "AllowExecutionFromApiGateway"
  ]
  actions = [
    "lambda:InvokeFunction"
  ]
  principals = [
    "apigateway.amazonaws.com"
  ]
  variables = {
    foo = "bar"
  }
}


####----------------------------------------------------------------------------------
## REST API
####----------------------------------------------------------------------------------
module "rest_api" {
  source = "../../../"

  name                        = "${local.name}-rest-api"
  environment                 = local.environment
  domain_name_certificate_arn = module.acm.arn
  create_rest_api             = true
  rest_api_description        = "REST API for ${module.lambda.name} lambda function"
  rest_api_endpoint_type      = "REGIONAL"
  integration_uri             = module.lambda.invoke_arn
  rest_api_stage_name         = "test"
  api_resources = {
    users = {
      path_part   = "users"
      http_method = "ANY"
      uri         = module.lambda.invoke_arn

    },
    cards = {
      path_part   = "cards"
      http_method = "ANY"
      uri         = module.lambda.invoke_arn
    }
  }

  # -- Required
  domain_name   = "api.${local.domain_name}"
  zone_id       = "Z01564602K369XB8xxxxx"
  rest_api_role = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


