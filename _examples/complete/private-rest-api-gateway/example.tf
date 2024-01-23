locals {
  name        = "api"
  environment = "test"
  domain_name = "clouddrove.ca"
  region      = "ap-south-1"
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
## REST API PRIVATE
####----------------------------------------------------------------------------------
module "vpc" {
  source  = "clouddrove/vpc/aws"
  version = "2.0.0"

  name        = "${local.name}-rest-api-private"
  environment = local.environment
  enable      = true
  cidr_block  = "10.0.0.0/16"

}

module "subnets" {
  source  = "clouddrove/subnet/aws"
  version = "2.0.1"

  name        = "${local.name}-rest-api-private"
  environment = local.environment

  nat_gateway_enabled = true
  single_nat_gateway  = true
  availability_zones  = ["${local.region}a", "${local.region}b", "${local.region}c"]
  vpc_id              = module.vpc.vpc_id
  type                = "public-private"
  igw_id              = module.vpc.igw_id
  cidr_block          = module.vpc.vpc_cidr_block
  ipv6_cidr_block     = module.vpc.ipv6_cidr_block
  enable_ipv6         = true
  private_inbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = "10.0.0.0/16"
      to_port     = "10.0.0.0/16"
      protocol    = "-1"
      cidr_block  = module.vpc.vpc_cidr_block
    }
  ]
  private_outbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = "10.0.0.0/16"
      to_port     = "10.0.0.0/16"
      protocol    = "-1"
      cidr_block  = module.vpc.vpc_cidr_block
    }
  ]
}

module "security_group" {
  source  = "clouddrove/security-group/aws"
  version = "2.0.0"

  name        = "${local.name}-rest-api-private"
  environment = local.environment

  vpc_id = module.vpc.vpc_id
  new_sg_ingress_rules_with_cidr_blocks = [
    {
      rule_count  = 1
      from_port   = "10.0.0.0/16"
      protocol    = "-1"
      to_port     = "10.0.0.0/16"
      cidr_blocks = [module.vpc.vpc_cidr_block]
      description = "Allow all traffic from ${local.environment} VPC."
    }
  ]
  new_sg_egress_rules_with_cidr_blocks = [
    {
      rule_count       = 1
      from_port        = "10.0.0.0/16"
      protocol         = "-1"
      to_port          = "10.0.0.0/16"
      cidr_blocks      = ["10.0.0.0/16"]
      ipv6_cidr_blocks = ["::/0"]
      description      = "Allow all outbound traffic."
    }
  ]
}

module "rest_api_private" {
  source = "../../../"

  name        = "${local.name}-rest-api-private"
  environment = local.environment

  create_rest_api        = true
  rest_api_endpoint_type = "PRIVATE"
  rest_api_description   = "Private REST API for ${module.lambda.name} lambda function"
  integration_uri        = module.lambda.invoke_arn
  rest_api_stage_name    = "test"
  auto_deploy            = true
  rest_api_base_path     = "test"
  # -- Required
  domain_name = "api.${local.domain_name}"
  zone_id     = "Z01564602K369XBxxxxx"

  # -- VPC Endpoint configuration
  vpc_id                      = module.vpc.vpc_id
  service_name                = "com.amazonaws.ap-south-1.execute-api"
  vpc_endpoint_type           = "Interface"
  private_dns_enabled         = true
  subnet_ids                  = module.subnets.private_subnet_id
  security_group_ids          = [module.security_group.security_group_id]
  domain_name_certificate_arn = module.acm.arn


}
