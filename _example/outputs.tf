output "api_id" {
  value       = join("", module.api_gateway.*.api_id)
  description = "The API identifier."
}

output "api_endpoint" {
  value       = join("", module.api_gateway.*.api_endpoint)
  description = "The URI of the API, of the form {api-id}.execute-api.{region}.amazonaws.com."
}

output "invoke_url" {
  value       = join("", module.api_gateway.*.invoke_url)
  description = "URL to invoke the API pointing to the stage"
}

output "integration_response_selection_expression" {
  value =  join("", module.api_gateway.*.integration_response_selection_expression)
  description = "The integration response selection expression for the integration."
}