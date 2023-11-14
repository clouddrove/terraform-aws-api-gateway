variable "name" {
  type        = string
  default     = "api"
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "environment" {
  type        = string
  default     = "test"
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "repository" {
  type        = string
  default     = ""
  description = "Terraform current module repo"
}

variable "label_order" {
  type        = list(any)
  default     = ["name", "environment"]
  description = "Label order, e.g. `name`,`application`."
}

variable "managedby" {
  type        = string
  default     = "hello@clouddrove.com"
  description = "ManagedBy, eg 'CloudDrove'"
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
  description = "Settings for logging access in this stage."
}

variable "default_route_settings" {
  type        = map(string)
  default     = {}
  description = "Default route settings for the stage."
}

variable "create_default_stage_enabled" {
  type        = bool
  default     = true
  description = "Flag to control the stage creation."
}

variable "default_stage_access_log_destination_arn" {
  type        = string
  default     = null
  description = "ARN of the CloudWatch Logs log group to receive access logs. "
}

variable "default_stage_access_log_format" {
  type        = string
  default     = null
  description = "Single line format of the access logs of data. Refer to log settings for HTTP or Websocket."
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

variable "zone_id" {
  type        = string
  default     = ""
  description = "The ID of the hosted zone to contain this record."
}
variable "integration_uri" {
  type        = string
  default     = ""
  description = "URI of the Lambda function for a Lambda proxy integration, when integration_type is AWS_PROXY. For an HTTP integration, specify a fully-qualified URL."
}

variable "integration_type" {
  type        = string
  default     = "AWS_PROXY"
  description = "Integration type of an integration. Valid values: AWS (supported only for WebSocket APIs), AWS_PROXY, HTTP (supported only for WebSocket APIs), HTTP_PROXY, MOCK (supported only for WebSocket APIs). "
}

variable "authorizer_type" {
  type        = string
  default     = "JWT"
  description = "The authorizer type. Valid values: JWT, REQUEST. For WebSocket APIs, specify REQUEST for a Lambda function using incoming request parameters. For HTTP APIs, specify JWT to use JSON Web Tokens."
}

variable "identity_sources" {
  type        = list(string)
  default     = ["$request.header.Authorization"]
  description = "The identity sources for which authorization is requested."
}

variable "connection_type" {
  type        = string
  default     = "INTERNET"
  description = "Type of the network connection to the integration endpoint. Valid values: INTERNET, VPC_LINK. Default is INTERNET."
}
variable "integration_description" {
  type        = string
  default     = "Lambda example"
  description = "Description of the integration."
}

variable "integration_method" {
  type        = string
  default     = "POST"
  description = "Integration's HTTP method. Must be specified if integration_type is not MOCK."
}
variable "passthrough_behavior" {
  type        = string
  default     = "WHEN_NO_MATCH"
  description = "Pass-through behavior for incoming requests based on the Content-Type header in the request, and the available mapping templates specified as the request_templates attribute. "
}

variable "stage_name" {
  type        = string
  default     = null
  description = "Stage Name to be used, set to `$default` to use Invoke URL as your default webpage for lambda"
}

variable "auto_deploy" {
  type        = bool
  default     = false
  description = "Set this to true to enable stage Auto Deployment"
}
