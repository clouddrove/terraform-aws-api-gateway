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
## API GATEWAY
####----------------------------------------------------------------------------------
module "api_gateway" {
  source = "../../../"

  name                        = local.name
  environment                 = local.environment
  domain_name                 = "api.${local.domain_name}"
  domain_name_certificate_arn = module.acm.arn
  integration_uri             = module.lambda.invoke_arn
  zone_id                     = local.hosted_zone_id
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
      timeout_milliseconds   = 30000
    }
    "GET /some-route-with-authorizer" = {
      lambda_arn             = module.lambda.arn
      payload_format_version = "1.0"
      authorizer_key         = "cognito"
    }
    "POST /start-step-function" = {
      lambda_arn             = module.lambda.arn
      payload_format_version = "1.0"
      authorizer_key         = "cognito"
    }
  }
}