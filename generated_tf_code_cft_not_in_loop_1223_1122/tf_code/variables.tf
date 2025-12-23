# The full self-link of a Certificate Manager certificate to use for TLS inspection. e.g. projects/PROJECT_ID/locations/REGION/certificates/CERT_NAME
variable "certificate_manager_certificate" {
  description = "The full self-link of a Certificate Manager certificate to use for TLS inspection. e.g. projects/PROJECT_ID/locations/REGION/certificates/CERT_NAME"
  type        = string
  default     = null
}

# The IP address of the gateway.
variable "ip_address" {
  description = "The IP address of the gateway. This must be a valid, unused IP address from the proxy-only subnet. If not specified, an IP is automatically allocated."
  type        = string
  default     = null
}

# A map of key/value labels to apply to the gateway and policy resources.
variable "labels" {
  description = "A map of key/value labels to apply to the gateway and policy resources."
  type        = map(string)
  default     = {}
}

# The Google Cloud region where the Secure Web Proxy will be deployed.
variable "location" {
  description = "The Google Cloud region where the Secure Web Proxy will be deployed."
  type        = string
}

# The base name for the Secure Web Proxy gateway and its associated policy.
variable "name" {
  description = "The base name for the Secure Web Proxy gateway and its associated policy."
  type        = string
}

# The full self-link of the VPC network to which the gateway is attached. e.g. projects/PROJECT_ID/global/networks/VPC_NAME
variable "network" {
  description = "The full self-link of the VPC network to which the gateway is attached. e.g. projects/PROJECT_ID/global/networks/VPC_NAME"
  type        = string
}

# An optional description of the gateway policy.
variable "policy_description" {
  description = "An optional description of the gateway policy."
  type        = string
  default     = "Secure Web Proxy policy managed by Terraform."
}

# A list of objects defining the rules for the Secure Web Proxy policy.
variable "policy_rules" {
  description = "A list of objects defining the rules for the Secure Web Proxy policy. Each object represents a rule. The 'action' can be 'ALLOW' or 'DENY'. The 'session_matcher' is a CEL expression."
  type = list(object({
    name            = string
    description     = optional(string, null)
    enabled         = bool
    priority        = number
    action          = string
    session_matcher = string
    tls_inspected   = optional(bool, false)
  }))
  default = [
    {
      name            = "default-allow-all"
      description     = "A default rule to allow all traffic."
      enabled         = true
      priority        = 1000
      action          = "ALLOW"
      session_matcher = "true"
      tls_inspected   = false
    }
  ]
}

# The project ID where the Secure Web Proxy and its components will be created.
variable "project_id" {
  description = "The project ID where the Secure Web Proxy and its components will be created."
  type        = string
}

# The full self-link of the proxy-only subnet to which the gateway is attached. e.g. projects/PROJECT_ID/regions/REGION/subnetworks/SUBNET_NAME
variable "subnet" {
  description = "The full self-link of the proxy-only subnet to which the gateway is attached. e.g. projects/PROJECT_ID/regions/REGION/subnetworks/SUBNET_NAME"
  type        = string
}
