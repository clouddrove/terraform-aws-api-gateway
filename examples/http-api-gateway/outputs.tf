output "api_id" {
  value       = module.api_gateway.api_id
  description = "The API identifier."
}

output "api_arn" {
  value       = module.api_gateway.api_arn
  description = "The API arn."
}

output "api_endpoint" {
  value       = module.api_gateway.api_endpoint
  description = "The URI of the API, of the form {api-id}.execute-api.{region}.amazonaws.com."
}

output "invoke_url" {
  value       = module.api_gateway.invoke_url
  description = "URL to invoke the API pointing to the stage"
}
