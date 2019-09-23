# Module      : Api Gateway
# Description : Terraform module to create Api Gateway resource on AWS.
output "id" {
  value = concat(
    aws_api_gateway_rest_api.default.*.id,
  )[0]
  description = "The ID of the REST API."
}

output "execution_arn" {
  value = concat(
    aws_api_gateway_rest_api.default.*.execution_arn,
  )[0]
  description = "The Execution ARN of the REST API."
}

output "tags" {
  value       = module.labels.tags
  description = "A mapping of tags to assign to the resource."
}