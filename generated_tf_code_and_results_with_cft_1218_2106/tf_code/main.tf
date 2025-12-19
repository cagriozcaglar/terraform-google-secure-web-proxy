# This file contains the main resources for the Secure Web Proxy module.
locals {
  # Flag to enable/disable resource creation based on required inputs.
  # Creation is skipped if project_id or name are not provided.
  enabled = var.project_id != null && var.name != null

  # Transforms the list of rule objects into a map, using the rule name as the key.
  # This is necessary for using for_each in the rule resource block.
  rules_map = { for rule in var.rules : rule.name => rule }

  # Determines the CA Pool resource name to be used for the TLS inspection policy.
  # It prioritizes the resource name of the newly created CA pool if enabled, otherwise uses the provided existing CA pool ID.
  tls_inspection_policy_id = var.create_tls_inspection_ca_pool ? try(google_privateca_ca_pool.swp_ca_pool[0].id, null) : var.tls_inspection_ca_pool_id
}

# Creates a Certificate Authority (CA) Pool for TLS inspection.
# This resource is created conditionally based on the 'create_tls_inspection_ca_pool' variable and if the module is enabled.
resource "google_privateca_ca_pool" "swp_ca_pool" {
  # The count meta-argument controls the conditional creation of this resource.
  count = local.enabled && var.create_tls_inspection_ca_pool ? 1 : 0

  # The beta provider is required for this resource.
  provider = google-beta

  # The ID of the project in which the resource belongs.
  project = var.project_id

  # The user-supplied name for the CA Pool.
  name = var.ca_pool_config.name

  # The location for the CA Pool.
  location = var.ca_pool_config.location

  # The tier of this CaPool. Possible values are: ENTERPRISE, DEVOPS.
  tier = var.ca_pool_config.tier

  # The PublishingOptions specifies how clients get access to certificates and CRLs.
  publishing_options {
    # When true, publishes each CertificateAuthority's CA certificate and includes its URL in the "Authority Information Access" X.509 extension in all issued Certificates. If this is false, the CA certificate will not be published and the corresponding X.509 extension will not be written in issued certificates.
    publish_ca_cert = true
    # When true, publishes each CertificateAuthority's CRL and includes its URL in the "CRL Distribution Points" X.509 extension in all issued Certificates. If this is false, CRLs will not be published and the corresponding X.509 extension will not be written in issued certificates.
    publish_crl = true
  }
}

# Defines the main Gateway Security Policy.
# This policy acts as a container for security rules.
resource "google_network_security_gateway_security_policy" "default" {
  # The count meta-argument controls the conditional creation of this resource.
  count = local.enabled ? 1 : 0

  # The beta provider is required for this resource.
  provider = google-beta

  # The ID of the project in which the resource belongs.
  project = var.project_id

  # The name of the Gateway Security Policy.
  name = var.name

  # The location of the Gateway Security Policy.
  location = var.location

  # An optional description of this Gateway Security Policy.
  description = var.description

  # The resource name of a Private CA Pool to be used for TLS inspection. If left blank, TLS inspection is disabled.
  tls_inspection_policy = local.tls_inspection_policy_id
}

# Creates a set of Gateway Security Policy Rules based on the 'rules' input variable.
# Each rule defines specific criteria for matching and acting on network traffic.
resource "google_network_security_gateway_security_policy_rule" "default" {
  # The for_each meta-argument iterates over the map of rules defined in local.rules_map if the module is enabled.
  for_each = local.enabled ? local.rules_map : {}

  # The beta provider is required for this resource.
  provider = google-beta

  # The ID of the project in which the resource belongs.
  project = var.project_id

  # The name of the Gateway Security Policy this rule belongs to.
  gateway_security_policy = google_network_security_gateway_security_policy.default[0].name

  # The location of the Gateway Security Policy Rule.
  location = var.location

  # The name of the Gateway Security Policy Rule.
  name = each.value.name

  # An optional description of this rule.
  description = each.value.description

  # Whether the rule is enabled. If disabled, the rule is not enforced.
  enabled = each.value.enabled

  # Priority of the rule. Lower number indicates higher precedence.
  priority = each.value.priority

  # The basic profile of the rule. Possible values are: ALLOW, DENY.
  basic_profile = each.value.basic_profile

  # CEL expression for matching on session criteria.
  session_matcher = each.value.session_matcher

  # A CEL expression for matching on application criteria.
  # This is constructed from the input list of FQDNs.
  application_matcher = length(each.value.application_matcher) > 0 ? "host() in [${join(", ", [for fqdn in each.value.application_matcher : "\"${fqdn}\""])}]" : null

  # If enabled, connections matching this rule will be TLS inspected.
  tls_inspection_enabled = each.value.tls_inspection_enabled
}
