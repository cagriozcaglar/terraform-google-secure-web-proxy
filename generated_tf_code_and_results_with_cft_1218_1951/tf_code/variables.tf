# The variables.tf file defines the input variables for the module.
variable "project_id" {
  description = "The ID of the Google Cloud project where the resources will be created. If not provided, no resources will be created."
  type        = string
  default     = null
}

variable "name" {
  description = "A base name for the Secure Web Proxy resources, which will be used to name the gateway and security policy. If not provided, no resources will be created."
  type        = string
  default     = null
}

variable "location" {
  description = "The Google Cloud region where the Secure Web Proxy gateway will be deployed. If not provided, no resources will be created."
  type        = string
  default     = null
}

variable "network" {
  description = "The self-link of the VPC network to which the gateway is attached. If not provided, no resources will be created."
  type        = string
  default     = null
}

variable "subnetwork" {
  description = "The self-link of the subnet to which the gateway is attached. This subnet must be a proxy-only subnet. If not provided, no resources will be created."
  type        = string
  default     = null
}

variable "rules" {
  description = "A list of objects representing the security policy rules to create. `priority` is a number between 1 and 1000, where lower numbers indicate higher precedence. `basic_profile` must be one of 'ALLOW' or 'DENY'. `session_matcher` and `application_matcher` use Common Expression Language (CEL)."
  type = list(object({
    name                   = string
    description            = optional(string)
    enabled                = optional(bool, true)
    priority               = number
    basic_profile          = string
    session_matcher        = string
    application_matcher    = optional(string)
    tls_inspection_enabled = optional(bool)
  }))
  default  = []
  nullable = false
}

variable "gateway_description" {
  description = "An optional description for the Secure Web Proxy gateway."
  type        = string
  default     = null
}

variable "policy_description" {
  description = "An optional description for the Gateway Security Policy."
  type        = string
  default     = null
}

variable "tls_inspection_policy" {
  description = "The resource name of the Certificate Manager CA Pool to use for TLS inspection. Format: `projects/{project}/locations/{location}/caPools/{ca_pool}`. If not set, TLS inspection is disabled for the policy."
  type        = string
  default     = null
}

variable "scope" {
  description = "A user-defined scope name for the gateway. This is used to organize gateways."
  type        = string
  default     = "default-scope"
}

variable "ports" {
  description = "A list of ports that the gateway will listen on. Supported ports are 80 and 443."
  type        = list(number)
  default     = [443]
}
