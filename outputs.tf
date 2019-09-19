# Module      : Route53
# Description : Terraform module to create Route53 resource on AWS for managing queue.
output "id" {
  value = concat(
    aws_api_gateway_rest_api.default.*.id,
  )[0]
  description = "The ID of the REST API."
}

output "tags" {
  value       = module.labels.tags
  description = "A mapping of tags to assign to the resource."
}