##-------------------------------------------------------------
## HTTP / WEBSOCKET
##-------------------------------------------------------------
output "api_id" {
  value       = join("", aws_apigatewayv2_api.default[*].id)
  description = "The HTTP Api ID."
}

output "api_arn" {
  value       = join("", aws_apigatewayv2_api.default[*].arn)
  description = "The HTTP API ARN."
}

output "api_endpoint" {
  value       = join("", aws_apigatewayv2_api.default[*].api_endpoint)
  description = "The URI of the API, of the form {api-id}.execute-api.{region}.amazonaws.com."
}

output "invoke_url" {
  value       = join("", aws_apigatewayv2_stage.default[*].invoke_url)
  description = "URL to invoke the API pointing to the stage"
}

##-------------------------------------------------------------
## REST API
##-------------------------------------------------------------
output "rest_api_id" {
  value       = aws_api_gateway_rest_api.rest_api[*].id
  description = " The ID of the REST API"
}

output "rest_api_arn" {
  value       = join("", aws_api_gateway_rest_api.rest_api[*].arn)
  description = "The Rest Api Arn."
}

output "rest_api_invoke_url" {
  value       = join("", aws_api_gateway_stage.rest_api_stage[*].invoke_url)
  description = "The URL to invoke the API pointing to the stage"
}

output "rest_api_execution_arn" {
  value       = join("", aws_api_gateway_rest_api.rest_api[*].execution_arn)
  description = "Execution arn of rest api gateway."
}

output "rest_api_vpc_link_id" {
  value       = join("", aws_api_gateway_vpc_link.rest_api_vpc_link[*].id)
  description = "ID of the REST API VPC link, when one was created."
}

output "domain_name_regional_target" {
  value       = join("", aws_apigatewayv2_domain_name.default[*].domain_name_configuration[0].target_domain_name)
  description = "Regional target hostname of the custom domain, for a Route53 alias record."
}

output "domain_name_regional_zone_id" {
  value       = join("", aws_apigatewayv2_domain_name.default[*].domain_name_configuration[0].hosted_zone_id)
  description = "Hosted zone id of the custom domain's regional endpoint, for a Route53 alias record."
}

output "rest_api_stage_name" {
  value       = join("", aws_api_gateway_stage.rest_api_stage[*].stage_name)
  description = "Name of the REST API stage."
}
