####----------------------------------------------------------------------------------
## Provider block added, Use the Amazon Web Services (AWS) provider to interact with the many resources supported by AWS.
####----------------------------------------------------------------------------------
provider "aws" {
  region = "eu-west-1"
}

####----------------------------------------------------------------------------------
## This terraform module is designed to generate consistent label names and tags for resources.
####----------------------------------------------------------------------------------
module "acm" {
  source  = "clouddrove/acm/aws"
  version = "1.3.0"

  name        = "certificate"
  environment = "test"
  label_order = ["name", "environment"]

  enable_aws_certificate    = true
  domain_name               = "example.cam"
  subject_alternative_names = ["*.example.cam"]
  validation_method         = "DNS"
  enable_dns_validation     = false
}

####----------------------------------------------------------------------------------
## This terraform module is designed to generate consistent label names and tags for resources.
####----------------------------------------------------------------------------------
module "lambda" {
  source  = "clouddrove/lambda/aws"
  version = "1.3.0"

  name        = "lambda"
  environment = "test"
  label_order = ["name", "environment"]

  enabled  = true
  timeout  = 60
  filename = "./lambda_packages"
  handler  = "index.lambda_handler"
  runtime  = "python3.8"
  iam_actions = [
    "logs:CreateLogStream",
    "logs:CreateLogGroup",
    "logs:PutLogEvents"
  ]
  names = [
    "python_layer"
  ]
  layer_filenames = ["./lambda-test.zip"]
  compatible_runtimes = [
    ["python3.8"]
  ]
  statement_ids = [
    "AllowExecutionFromCloudWatch"
  ]
  actions = [
    "lambda:InvokeFunction"
  ]
  principals = [
    "events.amazonaws.com"
  ]
  source_arns = [module.api_gateway.api_arn]
  variables = {
    foo = "bar"
  }
}

####----------------------------------------------------------------------------------
## This terraform module is designed to generate consistent label names and tags for resources.
####----------------------------------------------------------------------------------
module "api_gateway" {
  source = "./../../"

  name        = "api"
  environment = "test"
  label_order = ["environment", "name"]

  domain_name                 = "example.cam"
  domain_name_certificate_arn = module.acm.arn
  integration_uri             = module.lambda.arn
  zone_id                     = "1234059QJ345674343"
  create_vpc_link_enabled     = false
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
  access_log_settings = {
    default_stage_access_log_destination_arn = "*"
    default_stage_access_log_format          = " HTTP"
  }
}