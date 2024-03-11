variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `api`)."
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
  description = "Set this to `false` to prevent resource creation by this terraform module."
}

##---------------------------------------------------------------------------------
## HTTP API
##---------------------------------------------------------------------------------

variable "create_http_api" {
  type        = bool
  default     = false
  description = "Flag to control creation of HTTP api."
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

##---------------------------------------------------------------------------------------
## REST API
##---------------------------------------------------------------------------------------

variable "create_rest_api" {
  type        = bool
  default     = false
  description = "Flag to control the rest api creation."
}

variable "rest_api_endpoint_type" {
  type        = string
  default     = null
  description = "(Required) List of endpoint types. This resource currently only supports managing a single value. Valid values: EDGE, REGIONAL or PRIVATE. If unspecified, defaults to EDGE."
}

variable "xray_tracing_enabled" {
  type        = bool
  default     = true
  description = "A flag to indicate whether to enable X-Ray tracing."
}

variable "vpc_endpoint_id" {
  type        = string
  default     = ""
  description = "ID of the vpc endpoint. Only applicable when "
}

variable "create_rest_api_deployment" {
  type        = bool
  default     = true
  description = "Flag to control the mapping creation."
}

variable "create_rest_api_gateway_method" {
  type        = bool
  default     = true
  description = "Flag to control the rest api gateway method creation."
}

variable "create_rest_api_gateway_integration" {
  type        = bool
  default     = true
  description = "Flag to control the rest api gateway integration creation."
}

variable "create_rest_api_gateway_stage" {
  type        = bool
  default     = true
  description = "Flag to control the rest api gateway stage creation."
}

variable "create_rest_api_gateway_method_response" {
  type        = bool
  default     = true
  description = "Flag to control the rest api gateway stage creation."
}

variable "create_rest_api_gateway_integration_response" {
  type        = bool
  default     = true
  description = "Flag to control the rest api gateway integration response creation."
}

variable "create_rest_api_gateway_authorizer" {
  type        = bool
  default     = true
  description = "Flag to control the rest api gateway authorizer creation."
}

variable "create_rest_api_gateway_resource" {
  type        = bool
  default     = true
  description = "flag to control the rest api gateway resources creation"
}

variable "gateway_authorizer" {
  type        = string
  default     = "demo"
  description = "flag to control the gateway authorizer name."
}

variable "status_code" {
  type        = string
  default     = "200"
  description = "flag to control the status code"
}

variable "description_gateway_stage" {
  type        = string
  default     = "demo-test"
  description = "(optional) describe your variable"
}

variable "gateway_integration_type" {
  type        = string
  default     = "AWS_PROXY"
  description = "flag tp control the gatway integration type. "
}

variable "integration_http_method" {
  type        = string
  default     = "POST"
  description = "flag to control the gateway intergration http method."
}

variable "http_method" {
  type        = string
  default     = "ANY"
  description = "HTTP method (GET, POST, PUT, DELETE, HEAD, OPTION, ANY) when calling the associated resource."
}

variable "authorization" {
  type        = string
  default     = "NONE"
  description = "  Required The type of authorization used for the method (NONE, CUSTOM, AWS_IAM, COGNITO_USER_POOLS)"
}

variable "rest_api_description" {
  type        = string
  default     = "test"
  description = "The description of the REST API"
}

variable "connection_rest_api_type" {
  type        = string
  default     = "INTERNET"
  description = "Valid values are INTERNET (default for connections through the public routable internet), and VPC_LINK (for private connections between API Gateway and a network load balancer in a VPC)."
}

variable "connection_id" {
  type        = string
  default     = ""
  description = "ID of the VpcLink used for the integration. Required if connection_type is VPC_LINK"
}

variable "credentials" {
  type        = string
  default     = ""
  description = "To specify an IAM Role for Amazon API Gateway to assume, use the role's ARN. To require that the caller's identity be passed through from the request, specify the string "
}

variable "request_templates" {
  type        = map(string)
  default     = null
  description = "Map of the integration's request templates."
}

variable "request_parameters" {
  type        = map(string)
  default     = null
  description = "Map of request query string parameters and headers that should be passed to the backend responder"
}

variable "cache_key_parameters" {
  type        = list(any)
  default     = []
  description = "List of cache key parameters for the integration."
}

variable "cache_namespace" {
  type        = string
  default     = ""
  description = "Integration's cache namespace."
}

variable "content_handling" {
  type        = string
  default     = "CONVERT_TO_TEXT"
  description = "Supported values are CONVERT_TO_BINARY and CONVERT_TO_TEXT. If this property is not defined, the request payload will be passed through from the method request to integration request without modification, provided that the passthroughBehaviors is configured to support payload pass-through."
}

variable "timeout_milliseconds" {
  type        = number
  default     = null
  description = "Custom timeout between 50 and 29,000 milliseconds. The default value is 29,000 milliseconds."
}

variable "api_deployment_description" {
  type        = string
  default     = "test"
  description = "flag to manage description of api deployment"
}

variable "stage_description" {
  type        = string
  default     = "test"
  description = "Description to set on the stage managed by the stage_name argument."
}

variable "rest_variables" {
  type        = map(string)
  default     = {}
  description = "Map to set on the stage managed by the stage_name argument."
}

variable "cache_cluster_enabled" {
  type        = bool
  default     = false
  description = "Whether a cache cluster is enabled for the stage"
}

variable "cache_cluster_size" {
  type        = string
  default     = "0.5"
  description = "Size of the cache cluster for the stage, if enabled. Allowed values include 0.5, 1.6, 6.1, 13.5, 28.4, 58.2, 118 and 237."
}

variable "client_certificate_id" {
  type        = string
  default     = ""
  description = "Identifier of a client certificate for the stage."
}

variable "documentation_version" {
  type        = string
  default     = ""
  description = "Version of the associated API documentation"
}

variable "stage_variables" {
  type        = map(string)
  default     = {}
  description = "Map that defines the stage variables"
}

variable "canary_settings" {
  type        = map(any)
  default     = {}
  description = "(optional) describe your variable"
}

variable "rest_api_stage_name" {
  type        = string
  default     = ""
  description = "The name of the stage"
}

variable "response_models" {
  type = map(string)
  default = {
    "application/json" = "Empty"
  }
  description = "A map of the API models used for the response's content type"
}

variable "response_parameters" {
  type        = map(bool)
  default     = {}
  description = "Map of response parameters that can be sent to the caller. For example: response_parameters { method.response.header.X-Some-Header = true } would define that the header X-Some-Header can be provided on the response"
}

variable "integration_response_parameters" {
  type        = map(string)
  default     = {}
  description = " Map of response parameters that can be read from the backend response. For example: response_parameters = { method.response.header.X-Some-Header = integration.response.header.X-Some-Other-Header }."
}

variable "identity_source" {
  type        = string
  default     = "method.request.header.Authorization"
  description = "Source of the identity in an incoming request. Defaults to method.request.header.Authorization. For REQUEST type, this may be a comma-separated list of values, including headers, query string parameters and stage variable"
}

variable "type" {
  type        = string
  default     = "TOKEN"
  description = "Type of the authorizer. Possible values are TOKEN for a Lambda function using a single authorization token submitted in a custom header, REQUEST for a Lambda function using incoming request parameters, or COGNITO_USER_POOLS for using an Amazon Cognito user pool. Defaults to TOKEN."
}

variable "authorizer_result_ttl_in_seconds" {
  type        = number
  default     = 300
  description = "TTL of cached authorizer results in seconds. Defaults to 300."
}

variable "provider_arns" {
  type        = set(string)
  default     = []
  description = "required for type COGNITO_USER_POOLS) List of the Amazon Cognito user pool ARNs. Each element is of this format: arn:aws:cognito-idp:{region}:{account_id}:userpool/{user_pool_id}."
}

variable "authorizer_iam_role" {
  type        = string
  default     = ""
  description = " Custome IAMRole for Authorizer Credentials."
}

variable "rest_api_assume_role_policy" {
  type        = string
  default     = ""
  description = "Custome Trust Relationship Policy for Authorizer IAMRole."
}

variable "rest_api_base_path" {
  type        = string
  default     = ""
  description = "Path segment that must be prepended to the path when accessing the API via this mapping. If omitted, the API is exposed at the root of the given domain."
}

variable "api_resources" {
  type        = map(map(string))
  default     = {}
  description = "flag to control of resources path"
}

variable "log_format" {
  description = " Formatting and values recorded in the logs. For more information on configuring the log format rules visit the AWS documentation"
  type        = string
  default     = <<EOF
  {
	"requestTime": "$context.requestTime",
	"requestId": "$context.requestId",
	"httpMethod": "$context.httpMethod",
	"path": "$context.path",
	"resourcePath": "$context.resourcePath",
	"status": $context.status,
	"responseLatency": $context.responseLatency,
  "xrayTraceId": "$context.xrayTraceId",
  "integrationRequestId": "$context.integration.requestId",
	"functionResponseStatus": "$context.integration.status",
  "integrationLatency": "$context.integration.latency",
	"integrationServiceStatus": "$context.integration.integrationStatus",
  "authorizeResultStatus": "$context.authorize.status",
	"authorizerServiceStatus": "$context.authorizer.status",
	"authorizerLatency": "$context.authorizer.latency",
	"authorizerRequestId": "$context.authorizer.requestId",
  "ip": "$context.identity.sourceIp",
	"userAgent": "$context.identity.userAgent",
	"principalId": "$context.authorizer.principalId",
	"cognitoUser": "$context.identity.cognitoIdentityId",
  "user": "$context.identity.user"
}
  EOF
}

variable "retention_in_days" {
  type        = number
  default     = null
  description = "Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653, and 0. If you select 0, the events in the log group are always retained and never expire."
}

variable "log_group_class" {
  type        = string
  default     = "STANDARD"
  description = " Specified the log class of the log group. Possible values are: STANDARD or INFREQUENT_ACCESS."
}

variable "skip_destroy" {
  type        = bool
  default     = null
  description = "Set to true if you do not wish the log group (and any logs it may contain) to be deleted at destroy time, and instead just remove the log group from the Terraform state."
}

variable "enable_access_logs" {
  type        = bool
  default     = true
  description = "flag to manage of cloudwatch log group creation"
}

variable "kms_key_arn" {
  type        = string
  default     = ""
  description = "Pass existing KMS key arn. Only applicable when `create_kms_key` is set to false."
}

variable "enable_key_rotation" {
  type        = bool
  default     = null
  description = "Specifies whether key rotation is enabled. Defaults to false."
}

variable "create_kms_key" {
  type        = bool
  default     = true
  description = "Set this to `false` to provide existing kms key arn in `kms_key_arn` variable."
}

variable "multi_region" {
  type        = bool
  default     = false
  description = "ndicates whether the KMS key is a multi-Region (true) or regional (false) key. Defaults to false."
}

##-----------------------------------------------------------------------
## VPC ENDPOINT
##-----------------------------------------------------------------------

variable "create_vpc_endpoint" {
  type        = bool
  default     = true
  description = "VPC endpoint is required to access api gateway url from outside the vpc. Set this to `false` to prevent vpc endpoint creation."
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "The ID of the VPC in which the endpoint will be used."
}

variable "service_name" {
  type        = string
  default     = ""
  description = "The service name. For AWS services the service name is usually in the form com.amazonaws.<region>.<service> (the SageMaker Notebook service is an exception to this rule, the service name is in the form aws.sagemaker.<region>.notebook)."
}

variable "vpc_endpoint_type" {
  type        = string
  default     = "Gateway"
  description = "The VPC endpoint type, Gateway, GatewayLoadBalancer, or Interface. Defaults to Gateway."
}

variable "private_dns_enabled" {
  type        = bool
  default     = false
  description = "AWS services and AWS Marketplace partner services only) Whether or not to associate a private hosted zone with the specified VPC. Applicable for endpoints of type Interface. Most users will want this enabled to allow services within the VPC to automatically use the endpoint. Defaults to false."
}

variable "rest_api_resource_policy" {
  type        = string
  default     = ""
  description = "(Optional) custom resource policy for private rest api."
}
