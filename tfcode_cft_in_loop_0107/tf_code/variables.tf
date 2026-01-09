variable "ca_pool" {
  description = "The resource ID of the Certificate Authority Service CA Pool to use for TLS inspection. If set, a TLS inspection policy will be created and associated with the gateway security policy. Format 'projects/{project}/locations/{location}/caPools/{ca_pool}'."
  type        = string
  default     = null
}

variable "labels" {
  description = "A map of labels to apply to the gateway resource."
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "A unique name for the Secure Web Proxy gateway and its associated resources. If not provided, no resources will be created."
  type        = string
  default     = null
}

variable "network" {
  description = "The self-link of the VPC network to which the Secure Web Proxy gateway is attached. A proxy-only subnetwork must exist in this network and region for the gateway to function. If not provided, no resources will be created."
  type        = string
  default     = null
}

variable "ports" {
  description = "A list of ports that the gateway will listen on."
  type        = list(number)
  default     = [443]
}

variable "project_id" {
  description = "The project ID to deploy the Secure Web Proxy resources in. If not provided, the provider project is used."
  type        = string
  default     = null
}

variable "region" {
  description = "The region to deploy the Secure Web Proxy resources in. If not provided, the provider region is used."
  type        = string
  default     = null
}

variable "scope" {
  description = "A scope defines context for the gateway. If not provided, the gateway name will be used as the scope."
  type        = string
  default     = null
}

variable "security_policy_rules" {
  description = <<-EOT
  A list of security policy rules to be created and attached to the gateway. Rules are evaluated in order of priority, from lowest to highest.
  Each rule object has the following fields:
  - `name`: (string) A unique name for the rule.
  - `description`: (string, optional) A description for the rule. Defaults to 'Managed by Terraform'.
  - `enabled`: (bool, optional) Whether the rule is enabled. Defaults to `true`.
  - `priority`: (number) The priority of the rule, from 0 to 999. Lower numbers have higher precedence.
  - `session_matcher`: (string) A CEL expression for session matching. For example, `host() == 'example.com'`.
  - `application_matcher`: (string, optional) A CEL expression for application matching. Defaults to `true`.
  - `basic_profile`: (string) The basic profile action. Must be 'ALLOW' or 'DENY'.
  - `tls_inspection_enabled`: (bool, optional) Whether to enable TLS inspection for this rule. Defaults to `false`. Requires `ca_pool` to be set on the module.
  EOT
  type = list(object({
    name                   = string
    description            = optional(string, "Managed by Terraform")
    enabled                = optional(bool, true)
    priority               = number
    session_matcher        = string
    application_matcher    = optional(string, "true")
    basic_profile          = string
    tls_inspection_enabled = optional(bool, false)
  }))
  default = []
}
