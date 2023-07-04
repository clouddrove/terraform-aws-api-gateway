module "labels" {
  source  = "clouddrove/labels/aws"
  version = "1.3.0"

  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
  repository  = var.repository
}

resource "aws_apigatewayv2_api" "default" {
  count = var.enabled && var.create_api_gateway_enabled ? 1 : 0

  name          = format("%s-api", module.labels.id)
  description   = var.api_description
  protocol_type = var.protocol_type
  version       = var.api_version
  body          = var.body

  route_selection_expression   = var.route_selection_expression
  api_key_selection_expression = var.api_key_selection_expression

  route_key       = var.route_key
  credentials_arn = var.credentials_arn
  target          = var.target

  dynamic "cors_configuration" {
    for_each = var.cors_configuration

    content {
      allow_credentials = lookup(cors_configuration.value.allow_credentials, null)
      allow_headers     = lookup(cors_configuration.value.allow_headers, null)
      allow_methods     = lookup(cors_configuration.value.allow_methods, null)
      allow_origins     = lookup(cors_configuration.value.allow_origins, null)
      expose_headers    = lookup(cors_configuration.value.expose_headers, null)
      max_age           = lookup(cors_configuration.value.max_age, null)
    }
  }

  tags = merge(
    module.labels.tags,
    {
      "Name" = format("%s", module.labels.id)
    }
  )
}

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
resource "aws_route53_record" "default" {
  count = var.enabled ? 1 : 0

  name    =  join("", aws_apigatewayv2_domain_name.default.*.domain_name)
  type    = "A"
  zone_id = "Z08295059QJZ2CJCU2HZ"

  alias {
    name                   = join("", aws_apigatewayv2_domain_name.default.*.domain_name_configuration[0].*.target_domain_name)
    zone_id                = join("", aws_apigatewayv2_domain_name.default.*.domain_name_configuration[0].*.hosted_zone_id)
    evaluate_target_health = false
  }
}


resource "aws_apigatewayv2_stage" "default" {
  count = var.enabled && var.create_default_stage_enabled ? 1 : 0

  api_id      = aws_apigatewayv2_api.default[0].id
  name        = "$default"
  auto_deploy = true

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
      route_key          = route_settings.key
      data_trace_enabled = lookup(route_settings.value, "data_trace_enabled", false)
      logging_level      = lookup(route_settings.value, "logging_level", null)

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

resource "aws_apigatewayv2_api_mapping" "default" {
  count = var.enabled && var.apigatewayv2_api_mapping_enabled ? 1 : 0

  api_id      = join("", aws_apigatewayv2_api.default.*.id)
  domain_name = join("", aws_apigatewayv2_domain_name.default.*.id)
  stage       = join("", aws_apigatewayv2_stage.default.*.id)
}

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
  target                              = "integrations/${aws_apigatewayv2_integration.default[each.key].id}"

}

resource "aws_apigatewayv2_integration" "default" {
  for_each = var.enabled && var.create_routes_and_integrations_enabled ? var.integrations : {}

  api_id      = aws_apigatewayv2_api.default[0].id
  description = lookup(each.value.description, null)

  integration_type    = lookup(each.value.integration_type, lookup(each.value.lambda_arn, "") != "" ? "AWS_PROXY" : "MOCK")
  integration_subtype = lookup(each.value.integration_subtype, null)
  integration_method  = lookup(each.value.integration_method, lookup(each.value.integration_subtype, null) == null ? "POST" : null)
  integration_uri     = lookup(each.value.lambda_arn, lookup(each.value.integration_uri, null))

  connection_type = lookup(each.value.connection_type, "INTERNET")
  connection_id   = lookup(aws_apigatewayv2_vpc_link.this[each.value["vpc_link"]].id, lookup(each.value.connection_id, null))

  payload_format_version    = lookup(each.value.payload_format_version, null)
  timeout_milliseconds      = lookup(each.value.timeout_milliseconds, null)
  passthrough_behavior      = lookup(each.value.passthrough_behavior, null)
  content_handling_strategy = lookup(each.value.content_handling_strategy, null)
  credentials_arn           = lookup(each.value.credentials_arn, null)
  request_parameters        = lookup(jsondecode(each.value["request_parameters"]), each.value["request_parameters"], null)

  dynamic "tls_config" {
    for_each = flatten([lookup(jsondecode(each.value["tls_config"]), each.value["tls_config"], [])])

    content {
      server_name_to_verify = tls_config.value["server_name_to_verify"]
    }
  }

  dynamic "response_parameters" {
    for_each = flatten([lookup(jsondecode(each.value["response_parameters"]), each.value["response_parameters"], [])])

    content {
      status_code = response_parameters.value["status_code"]
      mappings    = response_parameters.value["mappings"]
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_apigatewayv2_authorizer" "default" {
  for_each = var.enabled && var.create_routes_and_integrations_enabled ? var.authorizers : {}

  api_id = aws_apigatewayv2_api.default[0].id

  authorizer_type                   = lookup(each.value.authorizer_type, null)
  identity_sources                  = lookup(flatten([each.value.identity_sources]), null)
  name                              = lookup(each.value.name, null)
  authorizer_uri                    = lookup(each.value.authorizer_uri, null)
  authorizer_payload_format_version = lookup(each.value.authorizer_payload_format_version, null)
  authorizer_result_ttl_in_seconds  = lookup(each.value.authorizer_result_ttl_in_seconds, null)
  authorizer_credentials_arn        = lookup(each.value.authorizer_credentials_arn, null)
  enable_simple_responses           = lookup(each.value.enable_simple_responses, null)

  #  dynamic "jwt_configuration" {
  #    for_each = length(lookup(each.value.audience, [each.value.issuer], [])) > 0 ? [true] : []
  #
  #    content {
  #      audience = lookup(each.value.audience, null)
  #      issuer   = lookup(each.value.issuer, null)
  #    }
  #  }
}

resource "aws_apigatewayv2_vpc_link" "this" {
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
