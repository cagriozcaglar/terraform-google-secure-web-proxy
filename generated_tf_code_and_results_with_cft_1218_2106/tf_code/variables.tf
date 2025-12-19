# The ID of the project where the Secure Web Proxy resources will be deployed.
variable "project_id" {
  description = "The project ID to deploy the Secure Web Proxy resources in. If null, no resources will be created."
  type        = string
  default     = null
}

# The name for the Gateway Security Policy.
variable "name" {
  description = "The name for the Gateway Security Policy. If null, no resources will be created."
  type        = string
  default     = null
}

# The location for the Gateway Security Policy. Must be 'global'.
variable "location" {
  description = "The location for the Gateway Security Policy. This must be 'global'."
  type        = string
  default     = "global"

  validation {
    condition     = var.location == "global"
    error_message = "The location for Gateway Security Policy must be 'global'."
  }
}

# An optional description of this Gateway Security Policy.
variable "description" {
  description = "An optional description of this Gateway Security Policy."
  type        = string
  default     = "Secure Web Proxy policy managed by Terraform."
}

# If true, a new CA Pool will be created for TLS inspection.
variable "create_tls_inspection_ca_pool" {
  description = "If true, a new Certificate Authority (CA) Pool will be created for TLS inspection. If false, you can provide an existing CA Pool ID via 'tls_inspection_ca_pool_id'."
  type        = bool
  default     = false
}

# The resource ID of an existing CA Pool to use for TLS inspection.
variable "tls_inspection_ca_pool_id" {
  description = "The resource ID of an existing CA Pool to use for TLS inspection. This is used only when 'create_tls_inspection_ca_pool' is false."
  type        = string
  default     = null
}

# Configuration for the CA Pool to be created.
variable "ca_pool_config" {
  description = "Configuration for the CA Pool to be created if 'create_tls_inspection_ca_pool' is true."
  type = object({
    name     = string
    location = string
    tier     = string
  })
  default = {
    name     = "swp-tls-inspection-pool"
    location = "us-central1"
    tier     = "DEVOPS"
  }
}

# A list of rule objects to create for the Gateway Security Policy.
variable "rules" {
  description = "A list of rule objects to create for the Gateway Security Policy."
  type = list(object({
    name                   = string
    description            = optional(string, "Terraform-managed SWP rule.")
    enabled                = optional(bool, true)
    priority               = number
    basic_profile          = string
    session_matcher        = string
    application_matcher    = optional(list(string), [])
    tls_inspection_enabled = optional(bool, false)
  }))
  default = []
}
