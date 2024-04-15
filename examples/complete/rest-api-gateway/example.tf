####----------------------------------------------------------------------------------
## PROVIDER
####----------------------------------------------------------------------------------
provider "aws" {
  region = local.region
}

####----------------------------------------------------------------------------------
## LOCALS
####----------------------------------------------------------------------------------

locals {
  name           = "api"
  environment    = "test"
  region         = "us-east-1"
  domain_name    = "clouddrove.ca"
  hosted_zone_id = "Z015XXXXXXXXXXXXXXIEP"
}
####----------------------------------------------------------------------------------
## ACM
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
## LAMBDA
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
  create_rest_api             = true
  domain_name_certificate_arn = module.acm.arn
  domain_name                 = "api.${local.domain_name}"
  zone_id                     = local.hosted_zone_id
  rest_api_description        = "REST API for ${module.lambda.name} lambda function"
  rest_api_endpoint_type      = "REGIONAL"
  integration_uri             = module.lambda.invoke_arn
  rest_api_stage_name         = "default"
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

  #---access log----
  enable_access_logs = true
  retention_in_days  = 7
}






