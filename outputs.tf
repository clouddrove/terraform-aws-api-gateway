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
