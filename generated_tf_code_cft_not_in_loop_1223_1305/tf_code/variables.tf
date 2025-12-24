# The variables.tf file defines all the input variables that can be passed to the module.
variable "policy_description" {
  description = "A free-text description of the Gateway Security Policy."
  type        = string
  default     = "Gateway Security Policy managed by Terraform"
}

variable "policy_name" {
  description = "The name of the Gateway Security Policy."
  type        = string
  default     = "default-gateway-security-policy"
}

variable "project_id" {
  description = "The ID of the project in which the resource belongs. If not set, the provider project will be used."
  type        = string
  default     = null
}

variable "rules" {
  description = "A list of rule objects to create for the Gateway Security Policy. Each rule defines a condition and an action (ALLOW/DENY)."
  type = list(object({
    name                   = string
    description            = string
    enabled                = optional(bool, true)
    priority               = number
    basic_profile          = string
    session_matcher        = string
    application_matcher    = optional(string)
    tls_inspection_enabled = optional(bool, false)
  }))
  default = []
  validation {
    condition = alltrue([
      for rule in var.rules : contains(["ALLOW", "DENY"], rule.basic_profile)
    ])
    error_message = "The 'basic_profile' for each rule must be either 'ALLOW' or 'DENY'."
  }
  validation {
    condition = alltrue([
      for rule in var.rules : (rule.tls_inspection_enabled ? rule.application_matcher != null : true)
    ])
    error_message = "If 'tls_inspection_enabled' is true, 'application_matcher' must be specified."
  }
}
