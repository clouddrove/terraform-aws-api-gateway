## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_log\_settings | Settings for logging access in this stage. | `map(string)` | `{}` | no |
| api\_deployment\_description | flag to manage description of api deployment | `string` | `"test"` | no |
| api\_description | the description of the API. | `string` | `"Manages an Amazon API Gateway Version 2 API."` | no |
| api\_key\_selection\_expression | An API key selection expression. Valid values: $context.authorizer.usageIdentifierKey, $request.header.x-api-key. | `string` | `"$request.header.x-api-key"` | no |
| api\_resources | flag to control of resources path | `map(map(string))` | `{}` | no |
| api\_version | A version identifier for the API | `string` | `null` | no |
| apigatewayv2\_api\_mapping\_enabled | Flag to control the mapping creation. | `bool` | `true` | no |
| authorization | Required The type of authorization used for the method (NONE, CUSTOM, AWS\_IAM, COGNITO\_USER\_POOLS) | `string` | `"NONE"` | no |
| authorizer\_iam\_role | Custome IAMRole for Authorizer Credentials. | `string` | `""` | no |
| authorizer\_result\_ttl\_in\_seconds | TTL of cached authorizer results in seconds. Defaults to 300. | `number` | `300` | no |
| authorizer\_type | The authorizer type. Valid values: JWT, REQUEST. For WebSocket APIs, specify REQUEST for a Lambda function using incoming request parameters. For HTTP APIs, specify JWT to use JSON Web Tokens. | `string` | `"JWT"` | no |
| authorizers | Map of API gateway authorizers | `map(any)` | `{}` | no |
| auto\_deploy | Set this to true to enable stage Auto Deployment | `bool` | `false` | no |
| body | An OpenAPI specification that defines the set of routes and integrations to create as part of the HTTP APIs. Supported only for HTTP APIs. | `string` | `null` | no |
| cache\_cluster\_enabled | Whether a cache cluster is enabled for the stage | `bool` | `false` | no |
| cache\_cluster\_size | Size of the cache cluster for the stage, if enabled. Allowed values include 0.5, 1.6, 6.1, 13.5, 28.4, 58.2, 118 and 237. | `string` | `"0.5"` | no |
| cache\_key\_parameters | List of cache key parameters for the integration. | `list(any)` | `[]` | no |
| cache\_namespace | Integration's cache namespace. | `string` | `""` | no |
| canary\_settings | (optional) describe your variable | `map(any)` | `{}` | no |
| client\_certificate\_id | Identifier of a client certificate for the stage. | `string` | `""` | no |
| connection\_id | ID of the VpcLink used for the integration. Required if connection\_type is VPC\_LINK | `string` | `""` | no |
| connection\_rest\_api\_type | Valid values are INTERNET (default for connections through the public routable internet), and VPC\_LINK (for private connections between API Gateway and a network load balancer in a VPC). | `string` | `"INTERNET"` | no |
| connection\_type | Type of the network connection to the integration endpoint. Valid values: INTERNET, VPC\_LINK. Default is INTERNET. | `string` | `"INTERNET"` | no |
| content\_handling | Supported values are CONVERT\_TO\_BINARY and CONVERT\_TO\_TEXT. If this property is not defined, the request payload will be passed through from the method request to integration request without modification, provided that the passthroughBehaviors is configured to support payload pass-through. | `string` | `"CONVERT_TO_TEXT"` | no |
| cors\_configuration | The cross-origin resource sharing (CORS) configuration. Applicable for HTTP APIs. | `any` | `{}` | no |
| create\_api\_domain\_name\_enabled | Flag to control the domain creation. | `bool` | `true` | no |
| create\_default\_stage\_enabled | Flag to control the stage creation. | `bool` | `true` | no |
| create\_http\_api | Flag to control creation of HTTP api. | `bool` | `false` | no |
| create\_kms\_key | Set this to `false` to provide existing kms key arn in `kms_key_arn` variable. | `bool` | `true` | no |
| create\_rest\_api | Flag to control the rest api creation. | `bool` | `false` | no |
| create\_rest\_api\_deployment | Flag to control the mapping creation. | `bool` | `true` | no |
| create\_rest\_api\_gateway\_authorizer | Flag to control the rest api gateway authorizer creation. | `bool` | `true` | no |
| create\_rest\_api\_gateway\_integration | Flag to control the rest api gateway integration creation. | `bool` | `true` | no |
| create\_rest\_api\_gateway\_integration\_response | Flag to control the rest api gateway integration response creation. | `bool` | `true` | no |
| create\_rest\_api\_gateway\_method | Flag to control the rest api gateway method creation. | `bool` | `true` | no |
| create\_rest\_api\_gateway\_method\_response | Flag to control the rest api gateway stage creation. | `bool` | `true` | no |
| create\_rest\_api\_gateway\_resource | flag to control the rest api gateway resources creation | `bool` | `true` | no |
| create\_rest\_api\_gateway\_stage | Flag to control the rest api gateway stage creation. | `bool` | `true` | no |
| create\_routes\_and\_integrations\_enabled | Whether to create routes and integrations resources | `bool` | `true` | no |
| create\_vpc\_endpoint | VPC endpoint is required to access api gateway url from outside the vpc. Set this to `false` to prevent vpc endpoint creation. | `bool` | `true` | no |
| create\_vpc\_link\_enabled | Whether to create VPC links | `bool` | `true` | no |
| credentials | To specify an IAM Role for Amazon API Gateway to assume, use the role's ARN. To require that the caller's identity be passed through from the request, specify the string | `string` | `""` | no |
| credentials\_arn | Part of quick create. Specifies any credentials required for the integration. Applicable for HTTP APIs. | `string` | `null` | no |
| default\_route\_settings | Default route settings for the stage. | `map(string)` | `{}` | no |
| default\_stage\_access\_log\_destination\_arn | ARN of the CloudWatch Logs log group to receive access logs. | `string` | `null` | no |
| default\_stage\_access\_log\_format | Single line format of the access logs of data. Refer to log settings for HTTP or Websocket. | `string` | `null` | no |
| description\_gateway\_stage | (optional) describe your variable | `string` | `"demo-test"` | no |
| documentation\_version | Version of the associated API documentation | `string` | `""` | no |
| domain\_name | The domain name to use for API gateway | `string` | `null` | no |
| domain\_name\_certificate\_arn | The ARN of an AWS-managed certificate that will be used by the endpoint for the domain name | `string` | `""` | no |
| domain\_name\_ownership\_verification\_certificate\_arn | ARN of the AWS-issued certificate used to validate custom domain ownership (when certificate\_arn is issued via an ACM Private CA or mutual\_tls\_authentication is configured with an ACM-imported certificate.) | `string` | `null` | no |
| enable\_access\_logs | flag to manage of cloudwatch log group creation | `bool` | `true` | no |
| enable\_key\_rotation | Specifies whether key rotation is enabled. Defaults to false. | `bool` | `null` | no |
| enabled | Set this to `false` to prevent resource creation by this terraform module. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `"test"` | no |
| gateway\_authorizer | flag to control the gateway authorizer name. | `string` | `"demo"` | no |
| gateway\_integration\_type | flag tp control the gatway integration type. | `string` | `"AWS_PROXY"` | no |
| http\_method | HTTP method (GET, POST, PUT, DELETE, HEAD, OPTION, ANY) when calling the associated resource. | `string` | `"ANY"` | no |
| identity\_source | Source of the identity in an incoming request. Defaults to method.request.header.Authorization. For REQUEST type, this may be a comma-separated list of values, including headers, query string parameters and stage variable | `string` | `"method.request.header.Authorization"` | no |
| identity\_sources | The identity sources for which authorization is requested. | `list(string)` | <pre>[<br>  "$request.header.Authorization"<br>]</pre> | no |
| integration\_description | Description of the integration. | `string` | `"Lambda example"` | no |
| integration\_http\_method | flag to control the gateway intergration http method. | `string` | `"POST"` | no |
| integration\_method | Integration's HTTP method. Must be specified if integration\_type is not MOCK. | `string` | `"POST"` | no |
| integration\_response\_parameters | Map of response parameters that can be read from the backend response. For example: response\_parameters = { method.response.header.X-Some-Header = integration.response.header.X-Some-Other-Header }. | `map(string)` | `{}` | no |
| integration\_type | Integration type of an integration. Valid values: AWS (supported only for WebSocket APIs), AWS\_PROXY, HTTP (supported only for WebSocket APIs), HTTP\_PROXY, MOCK (supported only for WebSocket APIs). | `string` | `"AWS_PROXY"` | no |
| integration\_uri | URI of the Lambda function for a Lambda proxy integration, when integration\_type is AWS\_PROXY. For an HTTP integration, specify a fully-qualified URL. | `string` | `""` | no |
| integrations | Map of API gateway routes with integrations | `map(any)` | `{}` | no |
| kms\_key\_arn | Pass existing KMS key arn. Only applicable when `create_kms_key` is set to false. | `string` | `""` | no |
| label\_order | Label order, e.g. `name`,`application`. | `list(any)` | <pre>[<br>  "name",<br>  "environment"<br>]</pre> | no |
| log\_format | Formatting and values recorded in the logs. For more information on configuring the log format rules visit the AWS documentation | `string` | `"  {\n\t\"requestTime\": \"$context.requestTime\",\n\t\"requestId\": \"$context.requestId\",\n\t\"httpMethod\": \"$context.httpMethod\",\n\t\"path\": \"$context.path\",\n\t\"resourcePath\": \"$context.resourcePath\",\n\t\"status\": $context.status,\n\t\"responseLatency\": $context.responseLatency,\n  \"xrayTraceId\": \"$context.xrayTraceId\",\n  \"integrationRequestId\": \"$context.integration.requestId\",\n\t\"functionResponseStatus\": \"$context.integration.status\",\n  \"integrationLatency\": \"$context.integration.latency\",\n\t\"integrationServiceStatus\": \"$context.integration.integrationStatus\",\n  \"authorizeResultStatus\": \"$context.authorize.status\",\n\t\"authorizerServiceStatus\": \"$context.authorizer.status\",\n\t\"authorizerLatency\": \"$context.authorizer.latency\",\n\t\"authorizerRequestId\": \"$context.authorizer.requestId\",\n  \"ip\": \"$context.identity.sourceIp\",\n\t\"userAgent\": \"$context.identity.userAgent\",\n\t\"principalId\": \"$context.authorizer.principalId\",\n\t\"cognitoUser\": \"$context.identity.cognitoIdentityId\",\n  \"user\": \"$context.identity.user\"\n}\n"` | no |
| log\_group\_class | Specified the log class of the log group. Possible values are: STANDARD or INFREQUENT\_ACCESS. | `string` | `"STANDARD"` | no |
| managedby | ManagedBy, eg 'CloudDrove' | `string` | `"hello@clouddrove.com"` | no |
| multi\_region | ndicates whether the KMS key is a multi-Region (true) or regional (false) key. Defaults to false. | `bool` | `false` | no |
| mutual\_tls\_authentication | An Amazon S3 URL that specifies the truststore for mutual TLS authentication as well as version, keyed at uri and version | `map(string)` | `{}` | no |
| name | Name  (e.g. `app` or `api`). | `string` | `""` | no |
| passthrough\_behavior | Pass-through behavior for incoming requests based on the Content-Type header in the request, and the available mapping templates specified as the request\_templates attribute. | `string` | `"WHEN_NO_MATCH"` | no |
| private\_dns\_enabled | AWS services and AWS Marketplace partner services only) Whether or not to associate a private hosted zone with the specified VPC. Applicable for endpoints of type Interface. Most users will want this enabled to allow services within the VPC to automatically use the endpoint. Defaults to false. | `bool` | `false` | no |
| protocol\_type | The API protocol. Valid values: HTTP, WEBSOCKET | `string` | `"HTTP"` | no |
| provider\_arns | required for type COGNITO\_USER\_POOLS) List of the Amazon Cognito user pool ARNs. Each element is of this format: arn:aws:cognito-idp:{region}:{account\_id}:userpool/{user\_pool\_id}. | `set(string)` | `[]` | no |
| repository | Terraform current module repo | `string` | `""` | no |
| request\_parameters | Map of request query string parameters and headers that should be passed to the backend responder | `map(string)` | `null` | no |
| request\_templates | Map of the integration's request templates. | `map(string)` | `null` | no |
| response\_models | A map of the API models used for the response's content type | `map(string)` | <pre>{<br>  "application/json": "Empty"<br>}</pre> | no |
| response\_parameters | Map of response parameters that can be sent to the caller. For example: response\_parameters { method.response.header.X-Some-Header = true } would define that the header X-Some-Header can be provided on the response | `map(bool)` | `{}` | no |
| rest\_api\_assume\_role\_policy | Custome Trust Relationship Policy for Authorizer IAMRole. | `string` | `""` | no |
| rest\_api\_base\_path | Path segment that must be prepended to the path when accessing the API via this mapping. If omitted, the API is exposed at the root of the given domain. | `string` | `""` | no |
| rest\_api\_description | The description of the REST API | `string` | `"test"` | no |
| rest\_api\_endpoint\_type | (Required) List of endpoint types. This resource currently only supports managing a single value. Valid values: EDGE, REGIONAL or PRIVATE. If unspecified, defaults to EDGE. | `string` | `null` | no |
| rest\_api\_resource\_policy | (Optional) custom resource policy for private rest api. | `string` | `""` | no |
| rest\_api\_stage\_name | The name of the stage | `string` | `""` | no |
| rest\_variables | Map to set on the stage managed by the stage\_name argument. | `map(string)` | `{}` | no |
| retention\_in\_days | Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653, and 0. If you select 0, the events in the log group are always retained and never expire. | `number` | `null` | no |
| route\_key | Part of quick create. Specifies any route key. Applicable for HTTP APIs. | `string` | `null` | no |
| route\_selection\_expression | The route selection expression for the API. | `string` | `"$request.method $request.path"` | no |
| route\_settings | Settings for default route | `map(string)` | `{}` | no |
| security\_group\_ids | A list of security group IDs to associate with. | `list(string)` | `[]` | no |
| service\_name | The service name. For AWS services the service name is usually in the form com.amazonaws.<region>.<service> (the SageMaker Notebook service is an exception to this rule, the service name is in the form aws.sagemaker.<region>.notebook). | `string` | `""` | no |
| skip\_destroy | Set to true if you do not wish the log group (and any logs it may contain) to be deleted at destroy time, and instead just remove the log group from the Terraform state. | `bool` | `null` | no |
| stage\_description | Description to set on the stage managed by the stage\_name argument. | `string` | `"test"` | no |
| stage\_name | Stage Name to be used, set to `$default` to use Invoke URL as your default webpage for lambda | `string` | `null` | no |
| stage\_variables | Map that defines the stage variables | `map(string)` | `{}` | no |
| status\_code | flag to control the status code | `string` | `"200"` | no |
| subnet\_ids | A list of VPC Subnet IDs to launch in. | `list(string)` | `[]` | no |
| target | Part of quick create. Quick create produces an API with an integration, a default catch-all route, and a default stage which is configured to automatically deploy changes. For HTTP integrations, specify a fully qualified URL. For Lambda integrations, specify a function ARN. The type of the integration will be HTTP\_PROXY or AWS\_PROXY, respectively. Applicable for HTTP APIs. | `string` | `null` | no |
| timeout\_milliseconds | Custom timeout between 50 and 29,000 milliseconds. The default value is 29,000 milliseconds. | `number` | `null` | no |
| type | Type of the authorizer. Possible values are TOKEN for a Lambda function using a single authorization token submitted in a custom header, REQUEST for a Lambda function using incoming request parameters, or COGNITO\_USER\_POOLS for using an Amazon Cognito user pool. Defaults to TOKEN. | `string` | `"TOKEN"` | no |
| vpc\_endpoint\_id | ID of the vpc endpoint. Only applicable when | `string` | `""` | no |
| vpc\_endpoint\_type | The VPC endpoint type, Gateway, GatewayLoadBalancer, or Interface. Defaults to Gateway. | `string` | `"Gateway"` | no |
| vpc\_id | The ID of the VPC in which the endpoint will be used. | `string` | `""` | no |
| vpc\_links | Map of VPC Links details to create | `map(any)` | `{}` | no |
| xray\_tracing\_enabled | A flag to indicate whether to enable X-Ray tracing. | `bool` | `true` | no |
| zone\_id | The ID of the hosted zone to contain this record. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| api\_arn | The HTTP API ARN. |
| api\_endpoint | The URI of the API, of the form {api-id}.execute-api.{region}.amazonaws.com. |
| api\_id | The HTTP Api ID. |
| invoke\_url | URL to invoke the API pointing to the stage |
| rest\_api\_arn | The Rest Api Arn. |
| rest\_api\_execution\_arn | Execution arn of rest api gateway. |
| rest\_api\_id | The ID of the REST API |
| rest\_api\_invoke\_url | The URL to invoke the API pointing to the stage |

