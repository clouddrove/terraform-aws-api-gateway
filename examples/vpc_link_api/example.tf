####----------------------------------------------------------------------------------
## Provider block added, Use the Amazon Web Services (AWS) provider to interact with the many resources supported by AWS.
####----------------------------------------------------------------------------------
provider "aws" {
  region = "eu-west-1"
}

locals {
  vpc_cidr_block        = module.vpc.vpc_cidr_block
  additional_cidr_block = "172.16.0.0/16"
  name                  = "api"
  environment           = "test"
}
####----------------------------------------------------------------------------------
## A VPC is a virtual network that closely resembles a traditional network that you'd operate in your own data center.
####----------------------------------------------------------------------------------
module "vpc" {
  source  = "clouddrove/vpc/aws"
  version = "2.0.0"

  name        = local.name
  environment = local.environment
  cidr_block  = "172.16.0.0/16"
}

####----------------------------------------------------------------------------------
## A subnet is a range of IP addresses in your VPC.
####----------------------------------------------------------------------------------
#tfsec:ignore:aws-ec2-no-public-ip-subnet
module "public_subnets" {
  source  = "clouddrove/subnet/aws"
  version = "2.0.1"

  name               = local.name
  environment        = local.environment
  availability_zones = ["eu-west-1b", "eu-west-1c"]
  vpc_id             = module.vpc.vpc_id
  cidr_block         = module.vpc.vpc_cidr_block
  type               = "public"
  igw_id             = module.vpc.igw_id
  ipv6_cidr_block    = module.vpc.ipv6_cidr_block
}

##----------------------------------------------------------------------------------
## Below module will create SECURITY-GROUP and its components.
##----------------------------------------------------------------------------------

# ################################################################################
# Security Groups module call
################################################################################

module "ssh" {
  source  = "clouddrove/security-group/aws"
  version = "2.0.0"

  name        = local.name
  environment = local.environment
  vpc_id      = module.vpc.vpc_id
  new_sg_ingress_rules_with_cidr_blocks = [{
    rule_count  = 1
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = [local.vpc_cidr_block, local.additional_cidr_block]
    description = "Allow ssh traffic."
  }]

  ## EGRESS Rules
  new_sg_egress_rules_with_cidr_blocks = [{
    rule_count  = 1
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = [local.vpc_cidr_block, local.additional_cidr_block]
    description = "Allow ssh outbound traffic."
  }]
}

#tfsec:ignore:aws-ec2-no-public-egress-sgr
module "http_https" {
  source  = "clouddrove/security-group/aws"
  version = "2.0.0"

  name        = local.name
  environment = local.environment
  vpc_id      = module.vpc.vpc_id
  ## INGRESS Rules
  new_sg_ingress_rules_with_cidr_blocks = [{
    rule_count  = 1
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = [local.vpc_cidr_block]
    description = "Allow ssh traffic."
    },
    {
      rule_count  = 2
      from_port   = 80
      protocol    = "tcp"
      to_port     = 80
      cidr_blocks = [local.vpc_cidr_block]
      description = "Allow http traffic."
    },
    {
      rule_count  = 3
      from_port   = 443
      protocol    = "tcp"
      to_port     = 443
      cidr_blocks = [local.vpc_cidr_block]
      description = "Allow https traffic."
    },
    {
      rule_count  = 3
      from_port   = 3306
      protocol    = "tcp"
      to_port     = 3306
      cidr_blocks = [local.vpc_cidr_block]
      description = "Allow https traffic."
    }
  ]

  ## EGRESS Rules
  new_sg_egress_rules_with_cidr_blocks = [{
    rule_count       = 1
    from_port        = 0
    protocol         = "-1"
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow all traffic."
    }
  ]
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
  domain_name               = "clouddrove.ca"
  subject_alternative_names = ["*.clouddrove.ca"]
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
  filename    = "./lambda_packages"
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
## This terraform module is designed to generate consistent label names and tags for resources with vpc_link.
####----------------------------------------------------------------------------------
module "api_gateway" {
  source = "./../../"

  name                        = local.name
  environment                 = local.environment
  domain_name                 = "clouddrove.ca"
  create_vpc_link_enabled     = true
  zone_id                     = "1`23456059QJZ25345678"
  integration_uri             = module.lambda.arn
  domain_name_certificate_arn = module.acm.arn
  subnet_ids                  = tolist(module.public_subnets.public_subnet_id)
  security_group_ids          = [module.ssh.security_group_id, module.http_https.security_group_id]
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