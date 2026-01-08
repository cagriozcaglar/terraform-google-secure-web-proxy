variable "location" {
  description = "The Google Cloud region where the Secure Web Proxy will be deployed. If not provided, the provider's region is used."
  type        = string
  default     = null
}

variable "name" {
  description = "The base name for the Secure Web Proxy gateway and its associated security policy."
  type        = string
  default     = null
}

variable "network" {
  description = "The self-link of the VPC network to which the Secure Web Proxy is attached. E.g., 'projects/my-project/global/networks/my-network'."
  type        = string
  default     = null
}

variable "ports" {
  description = "A list of ports to which the gateway is bound. The gateway will listen on these ports for incoming traffic."
  type        = list(number)
  default     = [443]
}

variable "project_id" {
  description = "The project ID where the Secure Web Proxy and its components will be deployed. If not provided, the provider project is used."
  type        = string
  default     = null
}

variable "rules" {
  description = "A list of security policy rules to apply to the gateway. Rules are evaluated in order of their 'priority' field, from lowest to highest number. The 'name' of each rule must be unique within the policy."
  type = list(object({
    name                = string
    description         = optional(string)
    enabled             = bool
    priority            = number
    session_matcher     = string
    application_matcher = optional(string)
    basic_profile       = string
  }))
  default = [
    {
      name                = "allow-all-default"
      description         = "Default rule to allow all traffic."
      enabled             = true
      priority            = 1000
      session_matcher     = "true"
      application_matcher = null
      basic_profile       = "ALLOW"
    }
  ]

  validation {
    condition = alltrue([
      for rule in var.rules : contains(["ALLOW", "DENY"], rule.basic_profile)
    ])
    error_message = "The 'basic_profile' for each rule must be either 'ALLOW' or 'DENY'."
  }
}

variable "subnet" {
  description = "The self-link of the proxy-only subnet to which the Secure Web Proxy is attached. E.g., 'projects/my-project/regions/us-central1/subnetworks/my-proxy-subnet'."
  type        = string
  default     = null
}

variable "tls_inspection_policy" {
  description = "The self-link of an existing TLS Inspection Policy to be attached to the security policy for inspecting encrypted traffic. If set to null, TLS inspection is disabled."
  type        = string
  default     = null
}
