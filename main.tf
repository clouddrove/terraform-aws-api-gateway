##----------------------------------------------------------------------------------
## Labels module callled that will be used for naming and tags.
##----------------------------------------------------------------------------------
module "labels" {
  source  = "clouddrove/labels/aws"
  version = "1.3.0"

  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
  repository  = var.repository
}

##----------------------------------------------------------------------------------
## Below resource will Manages an Amazon API Gateway Version 2 API.
##----------------------------------------------------------------------------------
resource "aws_apigatewayv2_api" "default" {
  count = var.enabled && var.create_api_gateway_enabled ? 1 : 0

  name                         = format("%s", module.labels.id)
  description                  = var.api_description
  protocol_type                = var.protocol_type
  version                      = var.api_version
  body                         = var.body
  route_selection_expression   = var.route_selection_expression
  api_key_selection_expression = var.api_key_selection_expression
  route_key                    = var.route_key
  credentials_arn              = var.credentials_arn
  target                       = var.target
  dynamic "cors_configuration" {
    for_each = length(keys(var.cors_configuration)) == 0 ? [] : [var.cors_configuration]
    content {
      allow_credentials = try(cors_configuration.value.allow_credentials, null)
      allow_headers     = try(cors_configuration.value.allow_headers, null)
      allow_methods     = try(cors_configuration.value.allow_methods, null)
      allow_origins     = try(cors_configuration.value.allow_origins, null)
      expose_headers    = try(cors_configuration.value.expose_headers, null)
      max_age           = try(cors_configuration.value.max_age, null)
    }
  }
  tags = merge(
    module.labels.tags,
    {
      "Name" = format("%s", module.labels.id)
    }
  )
}

##----------------------------------------------------------------------------------
## Below resource will Manages an Amazon API Gateway Version 2 domain name.
##----------------------------------------------------------------------------------
resource "aws_apigatewayv2_domain_name" "default" {
  count = var.enabled && var.create_api_domain_name_enabled ? 1 : 0

  domain_name = var.domain_name
  domain_name_configuration {
    certificate_arn                        = var.domain_name_certificate_arn
    ownership_verification_certificate_arn = var.domain_name_ownership_verification_certificate_arn
    endpoint_type                          = "REGIONAL"
    security_policy                        = "TLS_1_2"
  }
  dynamic "mutual_tls_authentication" {
    for_each = var.mutual_tls_authentication
    content {
      truststore_uri     = mutual_tls_authentication.value.truststore_uri
      truststore_version = lookup(mutual_tls_authentication.value.truststore_version, null)
    }
  }
  tags = merge(
    module.labels.tags,
    {
      "Name" = format("%s-domain", module.labels.id)
    }
  )
}

##----------------------------------------------------------------------------------
## Below Provides a Route53 record resource.
##----------------------------------------------------------------------------------
resource "aws_route53_record" "default" {
  count = var.enabled ? 1 : 0

  name    = join("", aws_apigatewayv2_domain_name.default[*].domain_name)
  type    = "A"
  zone_id = var.zone_id
  alias {
    name                   = join("", aws_apigatewayv2_domain_name.default.*.domain_name_configuration[0].*.target_domain_name)
    zone_id                = join("", aws_apigatewayv2_domain_name.default.*.domain_name_configuration[0].*.hosted_zone_id)
    evaluate_target_health = false
  }
}

##----------------------------------------------------------------------------------
## Below Manages an Amazon API Gateway Version 2 stage.
##----------------------------------------------------------------------------------
#tfsec:ignore:aws-api-gateway-enable-access-logging
resource "aws_apigatewayv2_stage" "default" {
  count = var.enabled && var.create_default_stage_enabled ? 1 : 0

  api_id      = aws_apigatewayv2_api.default[0].id
  name        = format("%s-stage", module.labels.id)
  auto_deploy = false
  dynamic "access_log_settings" {
    for_each = var.access_log_settings
    content {
      destination_arn = var.default_stage_access_log_destination_arn
      format          = var.default_stage_access_log_format
    }
  }
  dynamic "default_route_settings" {
    for_each = var.default_route_settings

    content {
      data_trace_enabled = lookup(default_route_settings.value.data_trace_enabled, false)
      logging_level      = lookup(default_route_settings.value.logging_level, null)

      detailed_metrics_enabled = lookup(default_route_settings.value.detailed_metrics_enabled, false)
      throttling_burst_limit   = lookup(default_route_settings.value.throttling_burst_limit, null)
      throttling_rate_limit    = lookup(default_route_settings.value.throttling_rate_limit, null)
    }
  }
  dynamic "route_settings" {
    for_each = var.route_settings
    content {
      route_key                = route_settings.key
      data_trace_enabled       = lookup(route_settings.value, "data_trace_enabled", false)
      logging_level            = lookup(route_settings.value, "logging_level", null)
      detailed_metrics_enabled = lookup(route_settings.value, "detailed_metrics_enabled", false)
      throttling_burst_limit   = lookup(route_settings.value, "throttling_burst_limit", null)
      throttling_rate_limit    = lookup(route_settings.value, "throttling_rate_limit", null)
    }
  }
  tags = merge(
    module.labels.tags,
    {
      "Name" = format("%s-stage", module.labels.id)
    }
  )
}

##----------------------------------------------------------------------------------
## Below resource will Manages an Amazon API Gateway Version 2 API mapping.
##----------------------------------------------------------------------------------
resource "aws_apigatewayv2_api_mapping" "default" {
  count = var.enabled && var.apigatewayv2_api_mapping_enabled ? 1 : 0

  api_id      = join("", aws_apigatewayv2_api.default[*].id)
  domain_name = join("", aws_apigatewayv2_domain_name.default[*].id)
  stage       = join("", aws_apigatewayv2_stage.default[*].id)
}

##----------------------------------------------------------------------------------
## Below resource will Manages an Amazon API Gateway Version 2 route.
##----------------------------------------------------------------------------------
resource "aws_apigatewayv2_route" "default" {
  for_each = var.enabled && var.create_routes_and_integrations_enabled ? var.integrations : {}

  api_id    = aws_apigatewayv2_api.default[0].id
  route_key = each.key

  api_key_required                    = try(each.value.api_key_required, null)
  authorization_scopes                = try(split(",", each.value.authorization_scopes), null)
  authorization_type                  = try(each.value.authorization_type, "NONE")
  authorizer_id                       = try(aws_apigatewayv2_authorizer.default[each.value.authorizer_key].id, each.value.authorizer_id, null)
  model_selection_expression          = try(each.value.model_selection_expression, null)
  operation_name                      = try(each.value.operation_name, null)
  route_response_selection_expression = try(each.value.route_response_selection_expression, null)
  target                              = "integrations/${join("", aws_apigatewayv2_integration.default[*].id)}"
}

##----------------------------------------------------------------------------------
## Below resource will Manages an Amazon API Gateway Version 2 integration.
##----------------------------------------------------------------------------------
resource "aws_apigatewayv2_integration" "default" {
  count = var.enabled && var.create_routes_and_integrations_enabled ? 1 : 0

  api_id               = join("", aws_apigatewayv2_api.default[*].id)
  integration_type     = var.integration_type
  connection_type      = var.connection_type
  description          = var.integration_description
  integration_method   = var.integration_method
  integration_uri      = var.integration_uri
  passthrough_behavior = var.passthrough_behavior
}

##----------------------------------------------------------------------------------
## Below resource will Manages an Amazon API Gateway Version 2 authorizer.
##----------------------------------------------------------------------------------
resource "aws_apigatewayv2_authorizer" "default" {
  for_each = var.enabled && var.create_routes_and_integrations_enabled ? var.authorizers : {}

  api_id                            = aws_apigatewayv2_api.default[0].id
  authorizer_type                   = lookup(each.value.authorizer_type, null)
  identity_sources                  = lookup(flatten([each.value.identity_sources]), null)
  name                              = lookup(each.value.name, null)
  authorizer_uri                    = lookup(each.value.authorizer_uri, null)
  authorizer_payload_format_version = lookup(each.value.authorizer_payload_format_version, null)
  authorizer_result_ttl_in_seconds  = lookup(each.value.authorizer_result_ttl_in_seconds, null)
  authorizer_credentials_arn        = lookup(each.value.authorizer_credentials_arn, null)
  enable_simple_responses           = lookup(each.value.enable_simple_responses, null)
}

##----------------------------------------------------------------------------------
## Below resource will Manages an Amazon API Gateway Version 2 VPC Link.
##----------------------------------------------------------------------------------
resource "aws_apigatewayv2_vpc_link" "default" {
  for_each = var.enabled && var.create_vpc_link_enabled ? var.vpc_links : {}

  name               = format("%s", module.labels.id)
  security_group_ids = var.security_group_ids
  subnet_ids         = var.subnet_ids
  tags = merge(
    module.labels.tags,
    {
      "Name" = format("%s-vpc-link", module.labels.id)
    }
  )
}

##----------------------------------------------------------------------------------
## Below resource will Manages an Amazon API Gateway Version 2 authorizer.
##----------------------------------------------------------------------------------
resource "aws_apigatewayv2_authorizer" "some_authorizer" {
  count = var.enabled && var.create_routes_and_integrations_enabled ? 1 : 0

  api_id           = aws_apigatewayv2_api.default[0].id
  authorizer_type  = var.authorizer_type
  identity_sources = var.identity_sources
  name             = module.labels.id
  jwt_configuration {
    audience = ["example"]
    issuer   = "https://${aws_cognito_user_pool.default.endpoint}"
  }
}

##----------------------------------------------------------------------------------
## Below resource will Provides a Cognito User Pool resource.
##----------------------------------------------------------------------------------
resource "aws_cognito_user_pool" "default" {
  name = module.labels.id
}