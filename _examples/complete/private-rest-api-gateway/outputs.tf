##-------------------------------------------------------------
# REST API PRIVATE
##-------------------------------------------------------------

output "Private_rest_api_id" {
  value       = join(",", module.rest_api_private[*].rest_api_id)
  description = "The Rest api id "

}

output "Private_rest_api_arn" {
  value       = join(",", module.rest_api_private[*].rest_api_arn)
  description = "The Rest api arn"

}

output "Private_rest_api_invoke_url" {
  value       = join(",", module.rest_api_private[*].rest_api_invoke_url)
  description = "The Rest Api invoke URL"

}