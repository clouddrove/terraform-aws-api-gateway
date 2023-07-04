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

module "acm" {
  source  = "clouddrove/acm/aws"
  version = "1.3.0"

  name        = "certificate"
  environment = "test"
  label_order = ["name", "environment"]

  enable_aws_certificate    = true
  domain_name               = "test-clouddrove.com"
  subject_alternative_names = ["www.test-clouddrove.com"]
  validation_method         = "DNS"
  enable_dns_validation     = false
}

module "api_gateway" {
  source = "./../"

  name        = "api"
  environment = "test"
  label_order = ["environment", "name"]

  protocol_type               = "HTTP"
  domain_name                 = "test-clouddrove.com"
  domain_name_certificate_arn = module.acm.arn
  subnet_ids                  = tolist(module.public_subnets.public_subnet_id)
  security_group_ids          = [module.security_group.security_group_ids]
}