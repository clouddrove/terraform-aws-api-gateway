variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "repository" {
  type        = string
  default     = ""
  description = "Terraform current module repo"
}

variable "label_order" {
  type        = list(any)
  default     = []
  description = "Label order, e.g. `name`,`application`."
}

variable "managedby" {
  type        = string
  default     = "hello@clouddrove.com"
  description = "ManagedBy, eg 'CloudDrove'"
}

variable "attributes" {
  type        = list(any)
  default     = []
  description = "Additional attributes (e.g. `1`)."
}

variable "tags" {
  type        = map(any)
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)."
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Flag to control the api creation."
}

variable "create_api_gateway_enabled" {
  type        = bool
  default     = true
  description = "Flag to control the api creation."
}

variable "api_description" {
  type        = string
  default     = "Manages an Amazon API Gateway Version 2 API."
  description = "the description of the API."
}

variable "protocol_type" {
  type        = string
  default     = "HTTP"
  description = "The API protocol. Valid values: HTTP, WEBSOCKET"
}

variable "api_version" {
  type        = string
  default     = null
  description = "A version identifier for the API"
}

variable "body" {
  type        = string
  default     = null
  description = "An OpenAPI specification that defines the set of routes and integrations to create as part of the HTTP APIs. Supported only for HTTP APIs."
}

variable "route_selection_expression" {
  type        = string
  default     = "$request.method $request.path"
  description = "The route selection expression for the API."
}

variable "api_key_selection_expression" {
  type        = string
  default     = "$request.header.x-api-key"
  description = "An API key selection expression. Valid values: $context.authorizer.usageIdentifierKey, $request.header.x-api-key."
}

variable "route_key" {
  type        = string
  default     = null
  description = "Part of quick create. Specifies any route key. Applicable for HTTP APIs."
}

variable "credentials_arn" {
  type        = string
  default     = null
  description = "Part of quick create. Specifies any credentials required for the integration. Applicable for HTTP APIs."
}

variable "target" {
  type        = string
  default     = null
  description = "Part of quick create. Quick create produces an API with an integration, a default catch-all route, and a default stage which is configured to automatically deploy changes. For HTTP integrations, specify a fully qualified URL. For Lambda integrations, specify a function ARN. The type of the integration will be HTTP_PROXY or AWS_PROXY, respectively. Applicable for HTTP APIs."
}

variable "cors_configuration" {
  type        = any
  default     = {}
  description = "The cross-origin resource sharing (CORS) configuration. Applicable for HTTP APIs."
}

variable "mutual_tls_authentication" {
  type        = map(string)
  default     = {}
  description = "An Amazon S3 URL that specifies the truststore for mutual TLS authentication as well as version, keyed at uri and version"
}

variable "create_api_domain_name_enabled" {
  type        = bool
  default     = true
  description = "Flag to control the domain creation."
}

variable "domain_name" {
  type        = string
  default     = null
  description = "The domain name to use for API gateway"
}

variable "domain_name_certificate_arn" {
  type        = string
  default     = ""
  description = "The ARN of an AWS-managed certificate that will be used by the endpoint for the domain name"
}

variable "domain_name_ownership_verification_certificate_arn" {
  type        = string
  default     = null
  description = "ARN of the AWS-issued certificate used to validate custom domain ownership (when certificate_arn is issued via an ACM Private CA or mutual_tls_authentication is configured with an ACM-imported certificate.)"
}

variable "route_settings" {
  type        = map(string)
  default     = {}
  description = "Settings for default route"
}

variable "access_log_settings" {
  type        = map(string)
  default     = {}
  description = "Settings for default route"
}

variable "default_route_settings" {
  type        = map(string)
  default     = {}
  description = "Settings for default route"
}

variable "create_default_stage_enabled" {
  type        = bool
  default     = true
  description = "Flag to control the stage creation."
}

variable "default_stage_access_log_destination_arn" {
  type        = string
  default     = null
  description = "Default stage's ARN of the CloudWatch Logs log group to receive access logs. Any trailing :* is trimmed from the ARN."
}

variable "default_stage_access_log_format" {
  type        = string
  default     = null
  description = "Default stage's single line format of the access logs of data, as specified by selected $context variables."
}

variable "apigatewayv2_api_mapping_enabled" {
  type        = bool
  default     = true
  description = "Flag to control the mapping creation."
}

variable "create_routes_and_integrations_enabled" {
  type        = bool
  default     = true
  description = "Whether to create routes and integrations resources"
}

variable "integrations" {
  type        = map(any)
  default     = {}
  description = "Map of API gateway routes with integrations"
}

variable "authorizers" {
  type        = map(any)
  default     = {}
  description = "Map of API gateway authorizers"
}

variable "create_vpc_link_enabled" {
  type        = bool
  default     = true
  description = "Whether to create VPC links"
}

variable "vpc_links" {
  type        = map(any)
  default     = {}
  description = "Map of VPC Links details to create"
}

variable "subnet_ids" {
  type        = list(string)
  default     = []
  description = "A list of VPC Subnet IDs to launch in."
  sensitive   = true
}

variable "security_group_ids" {
  type        = list(string)
  default     = []
  description = "A list of security group IDs to associate with."
  sensitive   = true
}