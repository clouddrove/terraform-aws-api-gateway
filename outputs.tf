output "api_id" {
  value       = join("", aws_apigatewayv2_api.default.*.id)
  description = "The API identifier."
}

output "api_arn" {
  value       = join("", aws_apigatewayv2_api.default.*.arn)
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