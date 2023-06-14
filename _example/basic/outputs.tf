# Module      : Route53
# Description : Terraform module to create Route53 resource on AWS for managing queue.
output "arn" {
  value       = module.api-gateway.*.execution_arn
  description = "The Execution ARN of the REST API."
}

output "invoke_url" {
  value       = module.api-gateway.invoke_url
  description = " Input's URI. Required if type is AWS, AWS_PROXY, HTTP or HTTP_PROXY. For HTTP integrations, the URI must be a fully formed, encoded HTTP(S) URL according to the RFC-3986 specification "
  sensitive   = true
}

output "stage_name" {
  value       = module.api-gateway.stage_name
  description = "Name of the stage to create with this deployment. If the specified stage already exists, it will be updated to point to the new deployment."
}