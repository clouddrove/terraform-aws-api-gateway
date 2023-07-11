####----------------------------------------------------------------------------------
## Provider block added, Use the Amazon Web Services (AWS) provider to interact with the many resources supported by AWS.
####----------------------------------------------------------------------------------
provider "aws" {
  region = "eu-west-1"
}
####----------------------------------------------------------------------------------
## A VPC is a virtual network that closely resembles a traditional network that you'd operate in your own data center.
####----------------------------------------------------------------------------------
module "vpc" {
  source  = "clouddrove/vpc/aws"
  version = "1.3.1"

  name        = "vpc"
  environment = "test"
  label_order = ["name", "environment"]

  cidr_block = "172.16.0.0/16"
}

####----------------------------------------------------------------------------------
## A subnet is a range of IP addresses in your VPC.
####----------------------------------------------------------------------------------
module "public_subnets" {
  source  = "clouddrove/subnet/aws"
  version = "1.3.0"

  name        = "public-subnet"
  environment = "test"
  label_order = ["name", "environment"]

  availability_zones = ["eu-west-1b", "eu-west-1c"]
  vpc_id             = module.vpc.vpc_id
  cidr_block         = module.vpc.vpc_cidr_block
  type               = "public"
  igw_id             = module.vpc.igw_id
  ipv6_cidr_block    = module.vpc.ipv6_cidr_block
}

module "security_group" {
  source  = "clouddrove/security-group/aws"
  version = "1.3.0"

  name          = "security-group"
  environment   = "test"
  protocol      = "tcp"
  label_order   = ["environment", "name"]
  vpc_id        = module.vpc.vpc_id
  allowed_ip    = ["0.0.0.0/0"]
  allowed_ports = [3306]
}

module "iam-role" {
  source  = "clouddrove/iam-role/aws"
  version = "1.3.0"

  name               = "iam-role"
  environment        = "test"
  label_order        = ["name", "environment"]
  assume_role_policy = data.aws_iam_policy_document.default.json
  policy_enabled     = true
  policy             = data.aws_iam_policy_document.iam-policy.json
}

data "aws_iam_policy_document" "default" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "iam-policy" {
  statement {
    actions = [
      "ssm:UpdateInstanceInformation",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
    "ssmmessages:OpenDataChannel"]
    effect    = "Allow"
    resources = ["*"]
  }
}

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
  source_arns = [module.iam-role.arn]
  variables = {
    foo = "bar"
  }
}
module "api_gateway" {
  source = "./../"

  name        = "api"
  environment = "test"
  label_order = ["environment", "name"]

  protocol_type                = "HTTP"
  domain_name                  = "example.cam"
  domain_name_certificate_arn  = module.acm.arn
  subnet_ids                   = tolist(module.public_subnets.public_subnet_id)
  security_group_ids           = [module.security_group.security_group_ids]
  route_selection_expression   = "$request.method $request.path"
  api_key_selection_expression = "$request.header.x-api-key"
  cors_configuration = {
    allow_credentials = true
    allow_headers     = []
    allow_methods     = ["GET", "OPTIONS", "POST"]
    allow_origins     = []
    expose_headers    = []
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
  iam_arns        = module.iam-role.arn
  integration_uri = module.lambda.arn
  zone_id         = "1233xxxxxxxxxxxxxxxx"
}