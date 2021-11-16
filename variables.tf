#Module      : LABEL
#Description : Terraform label module variables
variable "name" {
  type        = string
  default     = ""
  description = "Name  (e.g. `app` or `cluster`)."
}

variable "repository" {
  type        = string
  default     = "https://github.com/clouddrove/terraform-aws-api-gateway"
  description = "Terraform current module repo"

  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^https://", var.repository))
    error_message = "The module-repo value must be a valid Git repo link."
  }

}

variable "environment" {
  type        = string
  default     = "https://registry.terraform.io/modules/clouddrove/api-gateway/aws"
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "label_order" {
  type        = list(any)
  default     = []
  description = "Label order, e.g. `name`,`application`."
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

variable "managedby" {
  type        = string
  default     = "hello@clouddrove.com"
  description = "ManagedBy, eg 'CloudDrove'."
}

# Module      : Api Gateway
# Description : Terraform Api Gateway module variables.
variable "enabled" {
  type        = bool
  default     = false
  description = "Whether to create rest api."
}

variable "description" {
  type        = string
  default     = ""
  description = "The description of the REST API "
}

variable "binary_media_types" {
  type        = list(any)
  default     = ["UTF-8-encoded"]
  description = "The list of binary media types supported by the RestApi. By default, the RestApi supports only UTF-8-encoded text payloads."
}

variable "minimum_compression_size" {
  type        = number
  default     = -1
  description = "Minimum response size to compress for the REST API. Integer between -1 and 10485760 (10MB). Setting a value greater than -1 will enable compression, -1 disables compression (default)."
}

variable "api_key_source" {
  type        = string
  default     = "HEADER"
  description = "The source of the API key for requests. Valid values are HEADER (default) and AUTHORIZER."
}

variable "types" {
  type        = list(any)
  default     = ["EDGE"]
  description = "Whether to create rest api."
}

variable "vpc_endpoint_ids" {
  type        = list(string)
  default     = ["", ]
  description = "Set of VPC Endpoint identifiers. It is only supported for PRIVATE endpoint type."
}

variable "path_parts" {
  type        = list(any)
  default     = []
  description = "The last path segment of this API resource."
}

variable "stage_enabled" {
  type        = bool
  default     = false
  description = "Whether to create stage for rest api."
}

variable "deployment_enabled" {
  type        = bool
  default     = false
  description = "Whether to deploy rest api."
}

variable "api_log_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable log for rest api."
}

variable "stage_name" {
  type        = string
  default     = ""
  description = "The name of the stage. If the specified stage already exists, it will be updated to point to the new deployment. If the stage does not exist, a new one will be created and point to this deployment."
}

variable "deploy_description" {
  type        = string
  default     = ""
  description = "The description of the deployment."
}

variable "stage_description" {
  type        = string
  default     = ""
  description = "The description of the stage."
}

variable "variables" {
  type        = map(any)
  default     = {}
  description = "A map that defines variables for the stage."
}

variable "method_enabled" {
  type        = bool
  default     = false
  description = "Whether to create stage for rest api."
}

variable "http_methods" {
  type        = list(any)
  default     = []
  description = "The HTTP Method (GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY)."
}

variable "authorizations" {
  type        = list(any)
  default     = []
  description = "The type of authorization used for the method (NONE, CUSTOM, AWS_IAM, COGNITO_USER_POOLS)."
}

variable "authorizer_ids" {
  type        = list(any)
  default     = []
  description = "The authorizer id to be used when the authorization is CUSTOM or COGNITO_USER_POOLS."
}

variable "authorization_scopes" {
  type        = list(any)
  default     = []
  description = "The authorization scopes used when the authorization is COGNITO_USER_POOLS."
  sensitive   = true
}

variable "api_key_requireds" {
  type        = list(any)
  default     = []
  description = "Specify if the method requires an API key."
  sensitive   = true
}

variable "request_models" {
  type        = list(any)
  default     = []
  description = "A map of the API models used for the request's content type where key is the content type (e.g. application/json) and value is either Error, Empty (built-in models) or aws_api_gateway_model's name."
}

variable "request_validator_ids" {
  type        = list(any)
  default     = []
  description = "The ID of a aws_api_gateway_request_validator."
  sensitive   = true
}

variable "request_parameters" {
  type        = list(any)
  default     = []
  description = "A map of request query string parameters and headers that should be passed to the integration. For example: request_parameters = {\"method.request.header.X-Some-Header\" = true \"method.request.querystring.some-query-param\" = true} would define that the header X-Some-Header and the query string some-query-param must be provided in the request."
}

variable "integration_http_methods" {
  type        = list(any)
  default     = []
  description = "The integration HTTP method (GET, POST, PUT, DELETE, HEAD, OPTIONs, ANY, PATCH) specifying how API Gateway will interact with the back end. Required if type is AWS, AWS_PROXY, HTTP or HTTP_PROXY. Not all methods are compatible with all AWS integrations. e.g. Lambda function can only be invoked via POST."
}

variable "integration_types" {
  type        = list(any)
  default     = []
  description = "The integration input's type. Valid values are HTTP (for HTTP backends), MOCK (not calling any real backend), AWS (for AWS services), AWS_PROXY (for Lambda proxy integration) and HTTP_PROXY (for HTTP proxy integration). An HTTP or HTTP_PROXY integration with a connection_type of VPC_LINK is referred to as a private integration and uses a VpcLink to connect API Gateway to a network load balancer of a VPC."
}

variable "connection_types" {
  type        = list(any)
  default     = []
  description = "The integration input's connectionType. Valid values are INTERNET (default for connections through the public routable internet), and VPC_LINK (for private connections between API Gateway and a network load balancer in a VPC)."
  sensitive   = true
}

variable "connection_ids" {
  type        = list(any)
  default     = []
  description = "The id of the VpcLink used for the integration. Required if connection_type is VPC_LINK."
  sensitive   = true
}

variable "uri" {
  type        = list(any)
  default     = []
  description = "The input's URI. Required if type is AWS, AWS_PROXY, HTTP or HTTP_PROXY. For HTTP integrations, the URI must be a fully formed, encoded HTTP(S) URL according to the RFC-3986 specification . For AWS integrations, the URI should be of the form arn:aws:apigateway:{region}:{subdomain.service|service}:{path|action}/{service_api}. region, subdomain and service are used to determine the right endpoint. e.g. arn:aws:apigateway:eu-west-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-1:012345678901:function:my-func/invocations."
  sensitive   = true
}

variable "credentials" {
  type        = list(any)
  default     = []
  description = "The credentials required for the integration. For AWS integrations, 2 options are available. To specify an IAM Role for Amazon API Gateway to assume, use the role's ARN. To require that the caller's identity be passed through from the request, specify the string arn:aws:iam::*:user/*."
  sensitive   = true
}

variable "integration_request_parameters" {
  type        = list(any)
  default     = []
  description = "A map of request query string parameters and headers that should be passed to the backend responder. For example: request_parameters = { \"integration.request.header.X-Some-Other-Header\" = \"method.request.header.X-Some-Header\" }."
}

variable "request_templates" {
  type        = list(any)
  default     = []
  description = "A map of the integration's request templates."
  sensitive   = true
}

variable "passthrough_behaviors" {
  type        = list(any)
  default     = []
  description = "The integration passthrough behavior (WHEN_NO_MATCH, WHEN_NO_TEMPLATES, NEVER). Required if request_templates is used."
}

variable "cache_key_parameters" {
  type        = list(any)
  default     = []
  description = "A list of cache key parameters for the integration."
  sensitive   = true
}

variable "cache_namespaces" {
  type        = list(any)
  default     = []
  description = "The integration's cache namespace."
  sensitive   = true
}

variable "content_handlings" {
  type        = list(any)
  default     = []
  description = "Specifies how to handle request payload content type conversions. Supported values are CONVERT_TO_BINARY and CONVERT_TO_TEXT. If this property is not defined, the request payload will be passed through from the method request to integration request without modification, provided that the passthroughBehaviors is configured to support payload pass-through."
}

variable "timeout_milliseconds" {
  type        = list(any)
  default     = []
  description = "Custom timeout between 50 and 29,000 milliseconds. The default value is 29,000 milliseconds."
}

variable "status_codes" {
  type        = list(any)
  default     = []
  description = "The HTTP status code."
}

variable "response_models" {
  type        = list(any)
  default     = []
  description = "A map of the API models used for the response's content type."
}

variable "response_parameters" {
  type        = list(any)
  default     = []
  description = "A map of response parameters that can be sent to the caller. For example: response_parameters = { \"method.response.header.X-Some-Header\" = true } would define that the header X-Some-Header can be provided on the response."
}

variable "integration_response_parameters" {
  type        = list(any)
  default     = []
  description = "A map of response parameters that can be read from the backend response. For example: response_parameters = { \"method.response.header.X-Some-Header\" = \"integration.response.header.X-Some-Other-Header\" }."
}

variable "response_templates" {
  type        = list(any)
  default     = []
  description = "A map specifying the templates used to transform the integration response body."
}

variable "response_content_handlings" {
  type        = list(any)
  default     = []
  description = "Specifies how to handle request payload content type conversions. Supported values are CONVERT_TO_BINARY and CONVERT_TO_TEXT. If this property is not defined, the response payload will be passed through from the integration response to the method response without modification."
}

variable "stage_names" {
  type        = list(any)
  default     = []
  description = "The name of the stage."
}

variable "cache_cluster_enableds" {
  type        = list(any)
  default     = []
  description = "Specifies whether a cache cluster is enabled for the stage."
}

variable "cache_cluster_sizes" {
  type        = list(any)
  default     = []
  description = "The size of the cache cluster for the stage, if enabled. Allowed values include 0.5, 1.6, 6.1, 13.5, 28.4, 58.2, 118 and 237."
}

variable "client_certificate_ids" {
  type        = list(any)
  default     = []
  description = "The identifier of a client certificate for the stage"
  sensitive   = true
}

variable "descriptions" {
  type        = list(any)
  default     = []
  description = "The description of the stage."
}

variable "documentation_versions" {
  type        = list(any)
  default     = []
  description = "The version of the associated API documentation."
}

variable "stage_variables" {
  type        = list(any)
  default     = []
  description = "A map that defines the stage variables."
}

variable "xray_tracing_enabled" {
  type        = list(any)
  default     = []
  description = "A mapping of tags to assign to the resource."
}

variable "destination_arns" {
  type        = list(any)
  default     = []
  description = "ARN of the log group to send the logs to. Automatically removes trailing :* if present."
  sensitive   = true
}

variable "formats" {
  type        = list(any)
  default     = []
  description = "The formatting and values recorded in the logs."
}

variable "cert_enabled" {
  type        = bool
  default     = false
  description = "Whether to create client certificate."
}

variable "cert_description" {
  type        = string
  default     = ""
  description = "The description of the client certificate."
}

variable "authorizer_names" {
  type        = list(any)
  default     = []
  description = "The name of the authorizer."
}

variable "authorizer_uri" {
  type        = list(any)
  default     = []
  description = "The authorizer's Uniform Resource Identifier (URI). This must be a well-formed Lambda function URI in the form of arn:aws:apigateway:{region}:lambda:path/{service_api}, e.g. arn:aws:apigateway:us-west-2:lambda:path/2015-03-31/functions/arn:aws:lambda:us-west-2:012345678912:function:my-function/invocations."
  sensitive   = true
}

variable "authorizer_credentials" {
  type        = list(any)
  default     = []
  description = "The credentials required for the authorizer. To specify an IAM Role for API Gateway to assume, use the IAM Role ARN."
  sensitive   = true
}

variable "authorizer_result_ttl_in_seconds" {
  type        = list(any)
  default     = []
  description = "The TTL of cached authorizer results in seconds. Defaults to 300."
}

variable "identity_sources" {
  type        = list(any)
  default     = []
  description = "The source of the identity in an incoming request. Defaults to method.request.header.Authorization. For REQUEST type, this may be a comma-separated list of values, including headers, query string parameters and stage variables - e.g. \"method.request.header.SomeHeaderName,method.request.querystring.SomeQueryStringName\"."
}

variable "authorizer_types" {
  type        = list(any)
  default     = []
  description = "The type of the authorizer. Possible values are TOKEN for a Lambda function using a single authorization token submitted in a custom header, REQUEST for a Lambda function using incoming request parameters, or COGNITO_USER_POOLS for using an Amazon Cognito user pool. Defaults to TOKEN."
}

variable "identity_validation_expressions" {
  type        = list(any)
  default     = []
  description = "A validation expression for the incoming identity. For TOKEN type, this value should be a regular expression. The incoming token from the client is matched against this expression, and will proceed if the token matches. If the token doesn't match, the client receives a 401 Unauthorized response."
}

variable "provider_arns" {
  type        = list(any)
  default     = []
  description = "required for type COGNITO_USER_POOLS) A list of the Amazon Cognito user pool ARNs. Each element is of this format: arn:aws:cognito-idp:{region}:{account_id}:userpool/{user_pool_id}."
  sensitive   = true
}

variable "authorizer_count" {
  type        = number
  default     = 0
  description = "Number of count to create Authorizers for api."
}

variable "gateway_response_count" {
  type        = number
  default     = 0
  description = "Number of count to create Gateway Response for api."
}

variable "response_types" {
  type        = list(any)
  default     = []
  description = "The response type of the associated GatewayResponse."
}

variable "gateway_status_codes" {
  type        = list(any)
  default     = []
  description = "The HTTP status code of the Gateway Response."
}

variable "gateway_response_templates" {
  type        = list(any)
  default     = []
  description = "A map specifying the parameters (paths, query strings and headers) of the Gateway Response."
}

variable "gateway_response_parameters" {
  type        = list(any)
  default     = []
  description = "A map specifying the templates used to transform the response body."
}

variable "model_count" {
  type        = number
  default     = 0
  description = "Number of count to create Model for api."
}

variable "model_names" {
  type        = list(any)
  default     = []
  description = "The name of the model."
}

variable "model_descriptions" {
  type        = list(any)
  default     = []
  description = "The description of the model."
}

variable "content_types" {
  type        = list(any)
  default     = []
  description = "The content type of the model."
}

variable "schemas" {
  type        = list(any)
  default     = []
  description = "The schema of the model in a JSON form."
}

variable "vpc_link_count" {
  type        = number
  default     = 0
  description = "Number of count to create VPC Link for api."
}

variable "vpc_link_names" {
  type        = list(any)
  default     = []
  description = "The name used to label and identify the VPC link."
}

variable "vpc_link_descriptions" {
  type        = list(any)
  default     = []
  description = "The description of the VPC link."
}

variable "target_arns" {
  type        = list(any)
  default     = []
  description = "The list of network load balancer arns in the VPC targeted by the VPC link. Currently AWS only supports 1 target."
  sensitive   = true
}

variable "key_count" {
  type        = number
  default     = 0
  description = "Number of count to create key for api gateway."
}

variable "key_names" {
  type        = list(any)
  default     = []
  description = "The name of the API key."
}

variable "key_descriptions" {
  type        = list(any)
  default     = []
  description = "The API key description. Defaults to \"Managed by Terraform\"."
}

variable "enableds" {
  type        = list(any)
  default     = []
  description = "Specifies whether the API key can be used by callers. Defaults to true."
}

variable "values" {
  type        = list(any)
  default     = []
  description = "The value of the API key. If not specified, it will be automatically generated by AWS on creation."
}

variable "api_policy" {
  default     = null
  description = "The policy document."
}

variable "model_schemas" {
  default     = []
  description = "The schema of the model in a JSON form."
}
