##-------------------------------------------------------------
# REST API
##-------------------------------------------------------------

output "rest_api_id" {
  value       = join(",", module.rest_api[*].rest_api_id)
  description = "The Rest api id "

}

output "rest_api_arn" {
  value       = join(",", module.rest_api[*].rest_api_arn)
  description = "The Rest api arn"
}

output "rest_api_invoke_url" {
  value       = join(",", module.rest_api[*].rest_api_invoke_url)
  description = "The Rest Api invoke URL"

}