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
  region      = "eu-west-1"
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
## This terraform module is designed to generate consistent label names and tags for resources.
####----------------------------------------------------------------------------------
module "api_gateway" {
  source = "../../../"

  name                        = local.name
  environment                 = local.environment
  domain_name                 = "clouddrove.ca"
  domain_name_certificate_arn = module.acm.arn
  integration_uri             = module.lambda.invoke_arn
  zone_id                     = "Z01564602K369Xxxxxxx"
  auto_deploy                 = true
  stage_name                  = "$default"
  create_vpc_link_enabled     = false
  create_http_api             = true
  cors_configuration = {
    allow_credentials = true
    allow_methods     = ["GET", "OPTIONS", "POST"]
    max_age           = 5
  }
  integrations = {
    "ANY /" = {
      lambda_arn             = module.lambda.arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
    }
    "GET /some-route-with-authorizer" = {
      lambda_arn             = module.lambda.arn
      payload_format_version = "2.0"
      authorizer_key         = "cognito"
    }
    "POST /start-step-function" = {
      lambda_arn             = module.lambda.arn
      payload_format_version = "2.0"
      authorizer_key         = "cognito"
    }
  }
}