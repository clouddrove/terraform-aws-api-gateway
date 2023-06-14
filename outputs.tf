# Module      : Api Gateway
# Description : Terraform Api Gateway module outputs.
output "id" {
  value       = join("", aws_api_gateway_rest_api.default.*.id)
  description = "The ID of the REST API."
}

output "execution_arn" {
  value       = join("", aws_api_gateway_rest_api.default.*.execution_arn)
  description = "The Execution ARN of the REST API."
}

output "tags" {
  value       = module.labels.tags
  description = "A mapping of tags to assign to the resource."
}

output "invoke_url" {
  value       = join("", aws_api_gateway_integration.default.*.uri)
  description = " Input's URI. Required if type is AWS, AWS_PROXY, HTTP or HTTP_PROXY. For HTTP integrations, the URI must be a fully formed, encoded HTTP(S) URL according to the RFC-3986 specification "
}

output "stage_name" {
  value       = join("", aws_api_gateway_deployment.default.*.stage_name)
  description = "Name of the stage to create with this deployment. If the specified stage already exists, it will be updated to point to the new deployment."
}