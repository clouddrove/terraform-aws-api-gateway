##-------------------------------------------------------------
# REST API PRIVATE
##-------------------------------------------------------------

output "Private_rest_api_id" {
  value       = module.rest_api_private.rest_api_id
  description = " The ID of the REST API"

}

output "Private_rest_api_arn" {
  value       = module.rest_api_private.rest_api_arn
  description = "The Rest api arn"

}

output "Private_rest_api_invoke_url" {
  value       = module.rest_api_private.rest_api_invoke_url
  description = "The URL to invoke the API pointing to the stage"

}