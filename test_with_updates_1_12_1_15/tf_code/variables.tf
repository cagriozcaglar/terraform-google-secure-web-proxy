variable "gateway_description" {
  description = "A description for the Secure Web Proxy gateway resource."
  type        = string
  default     = "Secure Web Proxy gateway managed by Terraform."
}

variable "gateway_ports" {
  description = "A list of ports (1-65535) on which the gateway will receive traffic."
  type        = list(number)
  default     = [443]
}

variable "labels" {
  description = "A map of key-value pairs to apply as labels to the gateway."
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "A unique name to be used as a prefix for the created gateway and security policy resources. If not provided, no resources will be created."
  type        = string
  default     = null
}

variable "network" {
  description = "The self-link of the VPC network to which the gateway is attached, e.g. projects/PROJECT_ID/global/networks/NETWORK_NAME. If not provided, no resources will be created."
  type        = string
  default     = null
}

variable "policy_description" {
  description = "A description for the Secure Web Proxy security policy resource."
  type        = string
  default     = "Secure Web Proxy security policy managed by Terraform."
}

variable "project_id" {
  description = "The GCP project ID where the Secure Web Proxy resources will be created. If not provided, the provider project will be used."
  type        = string
  default     = null
}

variable "region" {
  description = "The GCP region where the Secure Web Proxy gateway will be deployed. If not provided, the provider region will be used."
  type        = string
  default     = null
}

variable "rules" {
  description = <<-EOT
    A list of security policy rule objects to create. Rules are evaluated in order of priority, from lowest to highest number.
    Each rule object has the following attributes:
    - `name` (string): The name of the rule.
    - `description` (string, optional): A description for the rule. Defaults to 'Managed by Terraform'.
    - `enabled` (bool, optional): Whether the rule is enabled. Defaults to true.
    - `priority` (number): The priority of the rule (0-1000). Lower numbers have higher priority.
    - `session_matcher` (string): A CEL expression to match sessions (e.g., `host().endsWith('.example.com')`).
    - `application_matcher` (string, optional): A CEL expression to match applications (e.g., `tls=true`).
    - `basic_profile` (string): The action to take. Must be 'ALLOW' or 'DENY'.
    - `tls_inspection_enabled` (bool, optional): Whether to enable TLS inspection for traffic matching this rule. Defaults to false.
  EOT
  type = list(object({
    name                   = string
    description            = optional(string, "Managed by Terraform")
    enabled                = optional(bool, true)
    priority               = number
    session_matcher        = string
    application_matcher    = optional(string)
    basic_profile          = string
    tls_inspection_enabled = optional(bool, false)
  }))
  default = []

  validation {
    condition     = alltrue([for r in var.rules : contains(["ALLOW", "DENY"], r.basic_profile)])
    error_message = "The 'basic_profile' attribute for each rule must be either 'ALLOW' or 'DENY'."
  }
}

variable "scope" {
  description = "A user-defined name for the scope of the gateway. This is used to organize gateways."
  type        = string
  default     = null
}

variable "tls_inspection_policy_certificate_id" {
  description = "The self-link of a Certificate Manager certificate to use for TLS inspection. If provided, TLS inspection is enabled on the policy."
  type        = string
  default     = null
}
