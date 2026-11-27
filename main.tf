##----------------------------------------------------------------------------------
## Labels module callled that will be used for naming and tags.
##----------------------------------------------------------------------------------
module "labels" {
  source  = "clouddrove/labels/aws"
  version = "1.3.1"

  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
  repository  = var.repository
  extra_tags  = var.tags
}

##----------------------------------------------------------------------------------
## Below resource will Manages an Amazon API Gateway Version 2 API.
##----------------------------------------------------------------------------------
resource "aws_apigatewayv2_api" "default" {
  count = var.enabled && var.create_http_api ? 1 : 0

  name                         = module.labels.id
  description                  = var.api_description
  protocol_type                = var.protocol_type
  version                      = var.api_version
  body                         = var.body
  fail_on_warnings             = var.fail_on_warnings
  route_selection_expression   = var.route_selection_expression
  api_key_selection_expression = var.api_key_selection_expression
  route_key                    = var.route_key
  credentials_arn              = var.credentials_arn
  target                       = var.target
  disable_execute_api_endpoint = var.disable_execute_api_endpoint
  ip_address_type              = var.ip_address_type
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
  tags = module.labels.tags
}

##----------------------------------------------------------------------------------
## Below resource will Manages an Amazon API Gateway Version 2 domain name.
##----------------------------------------------------------------------------------
resource "aws_apigatewayv2_domain_name" "default" {
  count = var.enabled && var.create_api_domain_name_enabled && (var.create_http_api || var.create_rest_api) ? 1 : 0

  domain_name = var.domain_name
  domain_name_configuration {
    certificate_arn                        = var.domain_name_certificate_arn
    ownership_verification_certificate_arn = var.domain_name_ownership_verification_certificate_arn
    endpoint_type                          = var.domain_name_endpoint_type
    security_policy                        = var.domain_name_security_policy
    ip_address_type                        = var.ip_address_type
  }

  dynamic "mutual_tls_authentication" {
    for_each = length(var.mutual_tls_authentication) > 0 ? [var.mutual_tls_authentication] : []
    content {
      truststore_uri     = mutual_tls_authentication.value["truststore_uri"]
      truststore_version = lookup(mutual_tls_authentication.value, "truststore_version", null)
    }
  }

  tags = module.labels.tags
}

##----------------------------------------------------------------------------------
## Below Provides a Route53 record resource.
##----------------------------------------------------------------------------------
resource "aws_route53_record" "default" {
  count = var.enabled && (var.create_http_api || var.create_rest_api) && var.rest_api_endpoint_type != "PRIVATE" && var.zone_id != "" ? 1 : 0

  name    = join("", aws_apigatewayv2_domain_name.default[*].domain_name)
  type    = "A"
  zone_id = var.zone_id
  alias {
    name                   = join("", aws_apigatewayv2_domain_name.default[*].domain_name_configuration[0].target_domain_name)
    zone_id                = join("", aws_apigatewayv2_domain_name.default[*].domain_name_configuration[0].hosted_zone_id)
    evaluate_target_health = false
  }
}

##----------------------------------------------------------------------------------
## Below Manages an Amazon API Gateway Version 2 stage.
##----------------------------------------------------------------------------------
#tfsec:ignore:aws-api-gateway-enable-access-logging
resource "aws_apigatewayv2_stage" "default" {
  count = var.enabled && var.create_default_stage_enabled && var.create_http_api ? 1 : 0

  api_id      = aws_apigatewayv2_api.default[0].id
  name        = var.stage_name != null ? var.stage_name : format("%s-stage", module.labels.id)
  auto_deploy = var.auto_deploy

  dynamic "access_log_settings" {
    for_each = length(var.access_log_settings) > 0 || var.enable_http_api_access_logs ? [1] : []
    content {
      destination_arn = var.default_stage_access_log_destination_arn != null ? var.default_stage_access_log_destination_arn : join("", aws_cloudwatch_log_group.http_api_log[*].arn)
      format          = var.default_stage_access_log_format != null ? var.default_stage_access_log_format : replace(var.log_format, "\n", "")
    }
  }

  dynamic "default_route_settings" {
    for_each = length(var.default_route_settings) > 0 ? [var.default_route_settings] : []

    content {
      data_trace_enabled       = try(default_route_settings.value.data_trace_enabled, false)
      logging_level            = try(default_route_settings.value.logging_level, null)
      detailed_metrics_enabled = try(default_route_settings.value.detailed_metrics_enabled, false)
      throttling_burst_limit   = try(default_route_settings.value.throttling_burst_limit, null)
      throttling_rate_limit    = try(default_route_settings.value.throttling_rate_limit, null)
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

  tags = module.labels.tags
}

##----------------------------------------------------------------------------------
## Below resource will Manages an Amazon API Gateway Version 2 API mapping.
##----------------------------------------------------------------------------------
resource "aws_apigatewayv2_api_mapping" "default" {
  count = var.enabled && var.apigatewayv2_api_mapping_enabled && var.create_http_api ? 1 : 0

  api_id      = join("", aws_apigatewayv2_api.default[*].id)
  domain_name = join("", aws_apigatewayv2_domain_name.default[*].id)
  stage       = join("", aws_apigatewayv2_stage.default[*].id)
}

##----------------------------------------------------------------------------------
## Below resource maps the same custom domain to a REST API stage. An
## apigatewayv2 domain name accepts REST API mappings, which is what lets a
## REST API sit behind a mutual-TLS custom domain.
##----------------------------------------------------------------------------------
resource "aws_apigatewayv2_api_mapping" "rest_api" {
  count = var.enabled && var.apigatewayv2_api_mapping_enabled && var.create_rest_api && var.create_api_domain_name_enabled ? 1 : 0

  api_id      = join("", aws_api_gateway_rest_api.rest_api[*].id)
  domain_name = join("", aws_apigatewayv2_domain_name.default[*].id)
  stage       = join("", aws_api_gateway_stage.rest_api_stage[*].stage_name)
}

##----------------------------------------------------------------------------------
## Below resource will Manages an Amazon API Gateway Version 2 route.
##----------------------------------------------------------------------------------
resource "aws_apigatewayv2_route" "default" {
  for_each = var.enabled && var.create_routes_and_integrations_enabled && var.create_http_api ? var.integrations : {}

  api_id    = aws_apigatewayv2_api.default[0].id
  route_key = each.key

  api_key_required                    = try(each.value.api_key_required, null)
  authorization_scopes                = try(split(",", each.value.authorization_scopes), null)
  authorization_type                  = try(each.value.authorization_type, "NONE")
  authorizer_id                       = try(aws_apigatewayv2_authorizer.default[each.value.authorizer_key].id, each.value.authorizer_id, null)
  model_selection_expression          = try(each.value.model_selection_expression, null)
  operation_name                      = try(each.value.operation_name, null)
  route_response_selection_expression = try(each.value.route_response_selection_expression, null)
  target                              = "integrations/${(aws_apigatewayv2_integration.default[each.key].id)}"
}

##----------------------------------------------------------------------------------
## Below resource will Manages an Amazon API Gateway Version 2 integration.
##----------------------------------------------------------------------------------

resource "aws_apigatewayv2_integration" "default" {
  for_each = var.enabled && var.create_routes_and_integrations_enabled && var.create_http_api ? var.integrations : {}

  api_id                        = join("", aws_apigatewayv2_api.default[*].id)
  integration_type              = try(each.value.integration_type, var.integration_type)
  connection_type               = try(each.value.connection_type, var.connection_type)
  connection_id                 = try(each.value.connection_id, each.value.vpc_link_key != null ? aws_apigatewayv2_vpc_link.default[each.value.vpc_link_key].id : null, null)
  credentials_arn               = try(each.value.credentials_arn, var.credentials_arn)
  description                   = try(each.value.description, var.integration_description)
  integration_method            = try(each.value.integration_method, var.integration_method)
  integration_uri               = try(each.value.integration_uri, each.value.lambda_arn, var.integration_uri)
  passthrough_behavior          = try(each.value.passthrough_behavior, var.passthrough_behavior)
  payload_format_version        = try(each.value.payload_format_version, null)
  timeout_milliseconds          = try(each.value.timeout_milliseconds, var.timeout_milliseconds)
  content_handling_strategy     = try(each.value.content_handling_strategy, null)
  request_parameters            = try(each.value.request_parameters, null)
  request_templates             = try(each.value.request_templates, null)
  template_selection_expression = try(each.value.template_selection_expression, null)

  dynamic "response_parameters" {
    for_each = try(each.value.response_parameters, [])
    content {
      mappings    = response_parameters.value.mappings
      status_code = response_parameters.value.status_code
    }
  }

  dynamic "tls_config" {
    for_each = try(each.value.tls_config, null) != null ? [each.value.tls_config] : []
    content {
      server_name_to_verify = try(tls_config.value.server_name_to_verify, null)
    }
  }
}

##----------------------------------------------------------------------------------
## Below resource will Manages an Amazon API Gateway Version 2 authorizer.
##----------------------------------------------------------------------------------
resource "aws_apigatewayv2_authorizer" "default" {
  for_each = var.enabled && var.create_routes_and_integrations_enabled && var.create_http_api ? var.authorizers : {}

  api_id                            = aws_apigatewayv2_api.default[0].id
  authorizer_type                   = try(each.value.authorizer_type, null)
  identity_sources                  = try(flatten([each.value.identity_sources]), null)
  name                              = try(each.value.name, each.key)
  authorizer_uri                    = try(each.value.authorizer_uri, null)
  authorizer_payload_format_version = try(each.value.authorizer_payload_format_version, null)
  authorizer_result_ttl_in_seconds  = try(each.value.authorizer_result_ttl_in_seconds, null)
  authorizer_credentials_arn        = try(each.value.authorizer_credentials_arn, null)
  enable_simple_responses           = try(each.value.enable_simple_responses, null)

  dynamic "jwt_configuration" {
    for_each = try(each.value.jwt_configuration, null) != null ? [each.value.jwt_configuration] : []
    content {
      audience = try(jwt_configuration.value.audience, null)
      issuer   = try(jwt_configuration.value.issuer, null)
    }
  }
}

##----------------------------------------------------------------------------------
## Below resource will Manages an Amazon API Gateway Version 2 VPC Link.
##----------------------------------------------------------------------------------
resource "aws_apigatewayv2_vpc_link" "default" {
  for_each = var.enabled && var.create_vpc_link_enabled && var.create_http_api ? var.vpc_links : {}

  name               = try(each.value.name, length(var.vpc_links) > 1 ? format("%s-%s", module.labels.id, each.key) : module.labels.id)
  security_group_ids = try(each.value.security_group_ids, var.security_group_ids)
  subnet_ids         = try(each.value.subnet_ids, var.subnet_ids)
  tags               = module.labels.tags
}

##----------------------------------------------------------------------------------
## Below resource will Manages an Amazon API Gateway Version 2 authorizer.
##----------------------------------------------------------------------------------
resource "aws_apigatewayv2_authorizer" "some_authorizer" {
  count = var.enabled && var.create_default_cognito_authorizer && var.create_routes_and_integrations_enabled && var.create_http_api ? 1 : 0

  api_id           = aws_apigatewayv2_api.default[0].id
  authorizer_type  = var.authorizer_type
  identity_sources = var.identity_sources
  name             = module.labels.id
  jwt_configuration {
    audience = ["example"]
    issuer   = "https://${aws_cognito_user_pool.default[0].endpoint}"
  }
}

##----------------------------------------------------------------------------------
## Below resource will Provides a Cognito User Pool resource.
##----------------------------------------------------------------------------------
resource "aws_cognito_user_pool" "default" {
  count = var.enabled && var.create_default_cognito_authorizer && var.create_routes_and_integrations_enabled && var.create_http_api ? 1 : 0
  name  = module.labels.id
}

##----------------------------------------------------------------------------------
## Below resource will Manages an Amazon HTTP API CloudWatch Log Group.
##----------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "http_api_log" {
  count             = var.enabled && var.create_http_api && var.create_default_stage_enabled && var.enable_http_api_access_logs && var.default_stage_access_log_destination_arn == null ? 1 : 0
  name              = "/aws/apigateway/${module.labels.id}"
  skip_destroy      = var.skip_destroy
  log_group_class   = var.log_group_class
  retention_in_days = var.retention_in_days
  kms_key_id        = var.create_kms_key ? join("", module.kms_key[*].key_arn) : var.kms_key_arn
  tags              = module.labels.tags
}

##----------------------------------------------------------------------------------
## Below resource will Provides a REST API resource.
##----------------------------------------------------------------------------------
resource "aws_api_gateway_rest_api" "rest_api" {
  count = var.enabled && var.create_rest_api ? 1 : 0

  name                         = module.labels.id
  description                  = var.rest_api_description
  body                         = var.rest_api_body
  put_rest_api_mode            = var.put_rest_api_mode
  binary_media_types           = var.binary_media_types
  minimum_compression_size     = var.minimum_compression_size
  api_key_source               = var.api_key_source
  security_policy              = var.rest_api_security_policy
  tags                         = module.labels.tags
  disable_execute_api_endpoint = var.disable_execute_api_endpoint

  endpoint_configuration {
    types            = [var.rest_api_endpoint_type]
    ip_address_type  = var.ip_address_type
    vpc_endpoint_ids = var.rest_api_endpoint_type == "PRIVATE" ? (var.create_vpc_endpoint ? [aws_vpc_endpoint.rest_api_private[0].id] : var.vpc_endpoint_id) : null
  }
}

##--------------------------------------------------------------------------------
# Resource Policy for [aws_api_gateway_rest_api.rest_api]
##--------------------------------------------------------------------------------
resource "aws_api_gateway_rest_api_policy" "rest_api_resource_policy" {
  count = var.enabled && var.create_rest_api && var.rest_api_endpoint_type == "PRIVATE" ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.rest_api[0].id
  policy      = var.rest_api_resource_policy != "" ? var.rest_api_resource_policy : <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Deny",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": "${aws_api_gateway_rest_api.rest_api[0].execution_arn}/*",
            "Condition": {
                "StringNotEquals": {
                    "aws:sourceVpce": "${aws_vpc_endpoint.rest_api_private[0].id}"
                }
            }
        },
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "execute-api:Invoke",
            "Resource": "${aws_api_gateway_rest_api.rest_api[0].execution_arn}/*"
        }
    ]
}
  EOF
}

##----------------------------------------------------------------------------------
## Below resource will Manages an Amazon REST API Gateway Deployment.
##----------------------------------------------------------------------------------

resource "aws_api_gateway_deployment" "rest_api_deployment" {
  count       = var.enabled && var.create_rest_api && var.create_rest_api_deployment ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.rest_api[0].id
  description = var.api_deployment_description
  variables   = var.rest_variables
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.rest_api[0].body,
      aws_api_gateway_rest_api.rest_api[0].root_resource_id,
      aws_api_gateway_method.rest_api_method[*].id,
      aws_api_gateway_integration.rest_api_integration[*].id,
      aws_api_gateway_resource.api_resources,
      aws_api_gateway_method.api_methods,
      aws_api_gateway_integration.api_integrations,
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}

##----------------------------------------------------------------------------------
## Below resource will Manages an Amazon REST API Gateway Resource.
##----------------------------------------------------------------------------------

resource "aws_api_gateway_resource" "api_resources" {
  for_each    = var.enabled && var.create_rest_api && var.create_rest_api_gateway_resource ? var.api_resources : {}
  rest_api_id = aws_api_gateway_rest_api.rest_api[0].id
  parent_id   = aws_api_gateway_rest_api.rest_api[0].root_resource_id
  path_part   = each.value.path_part
}

##----------------------------------------------------------------------------------
## Below resource will Manages an Amazon REST API Gateway Method.
##----------------------------------------------------------------------------------

resource "aws_api_gateway_method" "api_methods" {
  for_each             = var.enabled && var.create_rest_api && var.create_rest_api_gateway_method ? var.api_resources : {}
  rest_api_id          = aws_api_gateway_rest_api.rest_api[0].id
  resource_id          = aws_api_gateway_resource.api_resources[each.key].id
  http_method          = each.value.http_method
  authorization        = try(each.value.authorization, var.authorization)
  authorizer_id        = try(each.value.authorizer_id, null)
  api_key_required     = try(each.value.api_key_required, var.api_key_required)
  request_validator_id = try(aws_api_gateway_request_validator.default[each.value.request_validator_key].id, each.value.request_validator_id, null)
  request_parameters   = try(each.value.method_request_parameters, null)
  request_models       = try(each.value.request_models, null)
}

##----------------------------------------------------------------------------------
## Below resource will Manage a REST API Gateway VPC link (v1). A REST API
## private integration cannot use an apigatewayv2 VPC link, and its targets
## must be network load balancers.
##----------------------------------------------------------------------------------
resource "aws_api_gateway_vpc_link" "rest_api_vpc_link" {
  count = var.enabled && var.create_rest_api && var.create_rest_api_vpc_link_enabled ? 1 : 0

  name        = module.labels.id
  description = var.rest_api_vpc_link_description
  target_arns = var.rest_api_vpc_link_target_arns
  tags        = module.labels.tags
}

##----------------------------------------------------------------------------------
## Below resource will Manages an Amazon REST API Gateway Integration.
##----------------------------------------------------------------------------------

resource "aws_api_gateway_integration" "api_integrations" {
  for_each                = var.enabled && var.create_rest_api && var.create_rest_api_gateway_integration ? var.api_resources : {}
  rest_api_id             = aws_api_gateway_rest_api.rest_api[0].id
  resource_id             = aws_api_gateway_resource.api_resources[each.key].id
  http_method             = aws_api_gateway_method.api_methods[each.key].http_method
  integration_http_method = try(each.value.integration_http_method, var.integration_http_method)
  type                    = try(each.value.type, var.gateway_integration_type)
  uri                     = each.value.uri
  connection_type         = try(each.value.connection_type, var.connection_rest_api_type)
  connection_id           = var.connection_id != "" ? var.connection_id : join("", aws_api_gateway_vpc_link.rest_api_vpc_link[*].id)
  credentials             = var.credentials
  request_templates       = var.request_templates
  request_parameters      = var.request_parameters
  cache_namespace         = var.cache_namespace
  content_handling        = var.content_handling
  cache_key_parameters    = var.cache_key_parameters
  timeout_milliseconds    = try(each.value.timeout_milliseconds, var.timeout_milliseconds)
  response_transfer_mode  = try(each.value.response_transfer_mode, var.response_transfer_mode)
}


##----------------------------------------------------------------------------------
## Below resource will Manages an Amazon REST API Gateway Method.
##----------------------------------------------------------------------------------

resource "aws_api_gateway_method" "rest_api_method" {
  count            = var.enabled && var.create_rest_api && var.create_rest_api_gateway_method ? 1 : 0
  authorization    = var.authorization
  http_method      = var.http_method
  resource_id      = aws_api_gateway_rest_api.rest_api[0].root_resource_id
  rest_api_id      = aws_api_gateway_rest_api.rest_api[0].id
  api_key_required = var.api_key_required
}

##----------------------------------------------------------------------------------
## Below resource will Manages an Amazon REST API Gateway integration.
##----------------------------------------------------------------------------------

resource "aws_api_gateway_integration" "rest_api_integration" {
  count                   = var.enabled && var.create_rest_api && var.create_rest_api_gateway_integration ? 1 : 0
  rest_api_id             = aws_api_gateway_rest_api.rest_api[0].id
  resource_id             = aws_api_gateway_method.rest_api_method[0].resource_id
  http_method             = aws_api_gateway_method.rest_api_method[0].http_method
  integration_http_method = var.integration_http_method
  connection_type         = var.connection_rest_api_type
  connection_id           = var.connection_id != "" ? var.connection_id : join("", aws_api_gateway_vpc_link.rest_api_vpc_link[*].id)
  credentials             = var.credentials
  request_templates       = var.request_templates
  request_parameters      = var.request_parameters
  cache_namespace         = var.cache_namespace
  content_handling        = var.content_handling
  cache_key_parameters    = var.cache_key_parameters
  type                    = var.gateway_integration_type
  timeout_milliseconds    = var.timeout_milliseconds
  response_transfer_mode  = var.response_transfer_mode
  uri                     = var.integration_uri
}


##----------------------------------------------------------------------------------
## Below resource will Manages an Amazon REST API Gateway stage.
##----------------------------------------------------------------------------------

resource "aws_api_gateway_stage" "rest_api_stage" {
  count                 = var.enabled && var.create_rest_api && var.create_rest_api_gateway_stage ? 1 : 0
  description           = var.description_gateway_stage
  deployment_id         = aws_api_gateway_deployment.rest_api_deployment[0].id
  rest_api_id           = aws_api_gateway_rest_api.rest_api[0].id
  stage_name            = var.rest_api_stage_name
  cache_cluster_enabled = var.cache_cluster_enabled
  cache_cluster_size    = var.cache_cluster_size
  client_certificate_id = var.client_certificate_id
  documentation_version = var.documentation_version
  variables             = var.stage_variables
  xray_tracing_enabled  = var.xray_tracing_enabled

  dynamic "canary_settings" {
    for_each = length(var.canary_settings) > 0 ? [var.canary_settings] : []
    content {
      deployment_id            = aws_api_gateway_deployment.rest_api_deployment[0].id
      percent_traffic          = lookup(canary_settings.value, "percent_traffic", null)
      stage_variable_overrides = lookup(canary_settings.value, "stage_variable_overrides", null)
      use_stage_cache          = lookup(canary_settings.value, "use_stage_cache", null)
    }
  }

  dynamic "access_log_settings" {
    for_each = var.enable_access_logs == true ? [1] : []

    content {
      destination_arn = aws_cloudwatch_log_group.rest_api_log[0].arn
      format          = replace(var.log_format, "\n", "")
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = module.labels.tags
}

##----------------------------------------------------------------------------------
## Below resource will Manages an Amazon REST API Gateway Method Response.
##----------------------------------------------------------------------------------

resource "aws_api_gateway_method_response" "rest_api_method_response" {
  count               = var.enabled && var.create_rest_api_gateway_method_response && var.create_rest_api ? 1 : 0
  rest_api_id         = aws_api_gateway_rest_api.rest_api[0].id
  resource_id         = aws_api_gateway_rest_api.rest_api[0].root_resource_id
  http_method         = aws_api_gateway_method.rest_api_method[0].http_method
  status_code         = var.status_code
  response_models     = var.response_models
  response_parameters = var.response_parameters
}


##----------------------------------------------------------------------------------
## Below resource will Manages an Amazon REST API Gateway Integration Response.
##----------------------------------------------------------------------------------

resource "aws_api_gateway_integration_response" "rest_api_integration_response" {
  count               = var.enabled && var.create_rest_api_gateway_integration_response && var.create_rest_api ? 1 : 0
  rest_api_id         = aws_api_gateway_rest_api.rest_api[0].id
  resource_id         = aws_api_gateway_method.rest_api_method[0].resource_id
  http_method         = aws_api_gateway_method.rest_api_method[0].http_method
  status_code         = aws_api_gateway_method_response.rest_api_method_response[0].status_code
  content_handling    = var.content_handling
  response_parameters = var.integration_response_parameters
  depends_on = [
    aws_api_gateway_method.rest_api_method,
    aws_api_gateway_integration.rest_api_integration
  ]
}

##----------------------------------------------------------------------------------
## Below resource will Manages an Amazon REST API Gateway Authorizer.
##----------------------------------------------------------------------------------

resource "aws_api_gateway_authorizer" "rest_api_authorizer" {
  count                            = var.enabled && var.create_rest_api_gateway_authorizer && var.create_rest_api ? 1 : 0
  name                             = var.gateway_authorizer
  rest_api_id                      = aws_api_gateway_rest_api.rest_api[0].id
  authorizer_uri                   = var.integration_uri
  authorizer_credentials           = var.authorizer_iam_role != "" ? var.authorizer_iam_role : aws_iam_role.rest_api_iam_role[0].arn
  identity_source                  = var.identity_source
  type                             = var.type
  authorizer_result_ttl_in_seconds = var.authorizer_result_ttl_in_seconds
  provider_arns                    = var.provider_arns
}

##----------------------------------------------------------------------------------
## Below resource will Manages an Amazon REST API Base Path Mapping.
##----------------------------------------------------------------------------------

resource "aws_api_gateway_base_path_mapping" "rest_api_base_path" {
  count       = var.enabled && var.create_rest_api_gateway_authorizer && var.create_rest_api ? 1 : 0
  api_id      = aws_api_gateway_rest_api.rest_api[0].id
  domain_name = var.domain_name
  base_path   = var.rest_api_base_path
  stage_name  = var.rest_api_stage_name
}

##----------------------------------------------------------------------------------
## Below resource will Manages an Amazon API IAM role.
##----------------------------------------------------------------------------------
resource "aws_iam_role" "rest_api_iam_role" {
  count              = var.enabled && var.create_rest_api_gateway_authorizer && var.create_rest_api ? 1 : 0
  name               = format("%s-iam-role", module.labels.id)
  path               = "/"
  assume_role_policy = var.rest_api_assume_role_policy != "" ? var.rest_api_assume_role_policy : <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "Terraform"
    }
  ]
}
EOF

}


##----------------------------------------------------------------------------------
## Below resource will Manages an Amazon Rest API Cloudwatch Log Group.
##----------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "rest_api_log" {
  count             = var.enabled && var.create_rest_api && var.enable_access_logs ? 1 : 0
  name              = module.labels.id
  skip_destroy      = var.skip_destroy
  log_group_class   = var.log_group_class
  retention_in_days = var.retention_in_days
  kms_key_id        = var.create_kms_key ? module.kms_key.key_arn : var.kms_key_arn
  tags              = module.labels.tags
}

##----------------------------------------------------------------------------------
## Below resource will Manages an Amazon Rest API Kms Key.
##----------------------------------------------------------------------------------

module "kms_key" {
  source  = "clouddrove/kms/aws"
  version = "1.3.4"

  enabled             = var.enabled && ((var.create_rest_api && var.enable_access_logs) || (var.create_http_api && var.enable_http_api_access_logs)) && var.create_kms_key ? true : false
  name                = module.labels.id
  enable_key_rotation = var.enable_key_rotation
  multi_region        = var.multi_region
  policy              = join("", data.aws_iam_policy_document.cloudwatch[*].json)
}


##----------------------------------------------------------------------------------
## Below resource will Manages an Kms key JSON POlicy.
##----------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy_document" "cloudwatch" {
  count     = var.enabled && ((var.create_rest_api && var.enable_access_logs) || (var.create_http_api && var.enable_http_api_access_logs)) && var.create_kms_key ? 1 : 0
  policy_id = "key-policy-cloudwatch"
  statement {
    sid = "Enable IAM User Permissions"
    actions = [
      "kms:*",
    ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        format(
          "arn:%s:iam::%s:root",
          data.aws_partition.current.partition,
          data.aws_caller_identity.current.account_id
        )
      ]
    }
    resources = ["*"]
  }
  statement {
    sid = "AllowCloudWatchLogs"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        format(
          "logs.%s.amazonaws.com",
          data.aws_region.current.region
        )
      ]
    }
    resources = ["*"]
  }
}

##-----------------------------------------------------------------------
# REST API PRIVATE: This only requires VPC ENDPOINT and RESOURCE POLICY
##-----------------------------------------------------------------------
resource "aws_vpc_endpoint" "rest_api_private" {
  count = var.enabled && var.create_rest_api && var.rest_api_endpoint_type == "PRIVATE" && var.create_vpc_endpoint ? 1 : 0

  vpc_id              = var.vpc_id
  service_name        = var.service_name != "" ? var.service_name : "com.amazonaws.${data.aws_region.current.region}.execute-api"
  vpc_endpoint_type   = var.vpc_endpoint_type
  private_dns_enabled = var.private_dns_enabled
  subnet_ids          = var.subnet_ids
  security_group_ids  = var.security_group_ids
}

##----------------------------------------------------------------------------------
## Below resource will Manages Amazon REST API Gateway Method Settings (throttling, logging, caching).
##----------------------------------------------------------------------------------
resource "aws_api_gateway_method_settings" "default" {
  count = var.enabled && var.create_rest_api && var.create_rest_api_gateway_stage && length(var.rest_api_method_settings) > 0 ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.rest_api[0].id
  stage_name  = aws_api_gateway_stage.rest_api_stage[0].stage_name
  method_path = try(var.rest_api_method_settings.method_path, "*/*")

  settings {
    metrics_enabled                            = try(var.rest_api_method_settings.metrics_enabled, null)
    logging_level                              = try(var.rest_api_method_settings.logging_level, null)
    data_trace_enabled                         = try(var.rest_api_method_settings.data_trace_enabled, null)
    throttling_burst_limit                     = try(var.rest_api_method_settings.throttling_burst_limit, null)
    throttling_rate_limit                      = try(var.rest_api_method_settings.throttling_rate_limit, null)
    caching_enabled                            = try(var.rest_api_method_settings.caching_enabled, null)
    cache_ttl_in_seconds                       = try(var.rest_api_method_settings.cache_ttl_in_seconds, null)
    cache_data_encrypted                       = try(var.rest_api_method_settings.cache_data_encrypted, null)
    require_authorization_for_cache_control    = try(var.rest_api_method_settings.require_authorization_for_cache_control, null)
    unauthorized_cache_control_header_strategy = try(var.rest_api_method_settings.unauthorized_cache_control_header_strategy, null)
  }
}

##----------------------------------------------------------------------------------
## Below resource will Manages Amazon REST API Gateway Request Validators.
##----------------------------------------------------------------------------------
resource "aws_api_gateway_request_validator" "default" {
  for_each = var.enabled && var.create_rest_api ? var.request_validators : {}

  name                        = try(each.value.name, each.key)
  rest_api_id                 = aws_api_gateway_rest_api.rest_api[0].id
  validate_request_body       = try(each.value.validate_request_body, false)
  validate_request_parameters = try(each.value.validate_request_parameters, false)
}

##----------------------------------------------------------------------------------
## Below resource will Manages Amazon REST API Gateway Responses.
##----------------------------------------------------------------------------------
resource "aws_api_gateway_gateway_response" "default" {
  for_each = var.enabled && var.create_rest_api ? var.gateway_responses : {}

  rest_api_id         = aws_api_gateway_rest_api.rest_api[0].id
  response_type       = each.key
  status_code         = try(each.value.status_code, null)
  response_parameters = try(each.value.response_parameters, null)
  response_templates  = try(each.value.response_templates, null)
}

##----------------------------------------------------------------------------------
## Below resources will Manage Amazon REST API Gateway Usage Plans and API Keys.
##----------------------------------------------------------------------------------
resource "aws_api_gateway_usage_plan" "default" {
  count = var.enabled && var.create_rest_api && var.create_usage_plan ? 1 : 0

  name         = var.usage_plan_name != "" ? var.usage_plan_name : module.labels.id
  description  = var.usage_plan_description
  product_code = var.usage_plan_product_code
  tags         = module.labels.tags

  api_stages {
    api_id = aws_api_gateway_rest_api.rest_api[0].id
    stage  = aws_api_gateway_stage.rest_api_stage[0].stage_name
  }

  dynamic "quota_settings" {
    for_each = length(var.usage_plan_quota_settings) > 0 ? [var.usage_plan_quota_settings] : []
    content {
      limit  = quota_settings.value.limit
      offset = try(quota_settings.value.offset, null)
      period = quota_settings.value.period
    }
  }

  dynamic "throttle_settings" {
    for_each = length(var.usage_plan_throttle_settings) > 0 ? [var.usage_plan_throttle_settings] : []
    content {
      burst_limit = try(throttle_settings.value.burst_limit, null)
      rate_limit  = try(throttle_settings.value.rate_limit, null)
    }
  }
}

resource "aws_api_gateway_api_key" "default" {
  for_each = var.enabled && var.create_rest_api ? var.api_keys : {}

  name        = try(each.value.name, "${module.labels.id}-${each.key}")
  description = try(each.value.description, "Managed by Terraform")
  enabled     = try(each.value.enabled, true)
  value       = try(each.value.value, null)
  tags        = module.labels.tags
}

resource "aws_api_gateway_usage_plan_key" "default" {
  for_each = var.enabled && var.create_rest_api && var.create_usage_plan ? var.api_keys : {}

  key_id        = aws_api_gateway_api_key.default[each.key].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.default[0].id
}

##----------------------------------------------------------------------------------
## Below resource will Associate an AWS WAFv2 Web ACL with the REST API stage.
##----------------------------------------------------------------------------------
resource "aws_wafv2_web_acl_association" "rest_api" {
  count = var.enabled && var.create_rest_api && var.create_rest_api_gateway_stage && var.waf_acl_arn != "" ? 1 : 0

  resource_arn = aws_api_gateway_stage.rest_api_stage[0].arn
  web_acl_arn  = var.waf_acl_arn
}



