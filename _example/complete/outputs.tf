# Module      : Route53
# Description : Terraform module to create Route53 resource on AWS for managing queue.
output "arn" {
  value       = module.api-gateway.*.execution_arn
  description = "The Execution ARN of the REST API."
}
