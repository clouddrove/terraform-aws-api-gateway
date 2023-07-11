output "api_id" {
  value       = join("", aws_apigatewayv2_api.default.*.id)
  description = "The API identifier."
}

output "api_endpoint" {
  value       = join("", aws_apigatewayv2_api.default.*.api_endpoint)
  description = "The URI of the API, of the form {api-id}.execute-api.{region}.amazonaws.com."
}

output "invoke_url" {
  value       = join("", aws_apigatewayv2_stage.default.*.invoke_url)
  description = "URL to invoke the API pointing to the stage"
}

#output "integration_response_selection_expression" {
#  value =  aws_apigatewayv2_integration.default.*.integration_response_selection_expression
#  description = "The integration response selection expression for the integration."
#}