# The main.tf file contains the core logic for creating the Secure Web Proxy resources.

# This local block transforms the list of rules into a map for use with for_each.
locals {
  # Converts the input list of rules into a map where the key is the rule's name.
  # This is a standard pattern for creating multiple resources from a list variable.
  rules_map = { for rule in var.rules : rule.name => rule }
}

# This resource creates the Gateway Security Policy, which acts as a container for security rules.
resource "google_network_security_gateway_security_policy" "default" {
  # The beta provider is required for Secure Web Proxy resources.
  provider = google-beta

  # The name of the Gateway Security Policy.
  name = var.policy_name

  # A free-text description of the Gateway Security Policy.
  description = var.policy_description

  # The ID of the project in which the resource belongs. If not set, the provider project will be used.
  project = var.project_id

  # The location of the gateway security policy. Must be 'global'.
  location = "global"
}

# This resource creates individual rules within the Gateway Security Policy.
resource "google_network_security_gateway_security_policy_rule" "default" {
  # The beta provider is required for Secure Web Proxy resources.
  provider = google-beta

  # Iterates over the map of rules created in the locals block to create a rule for each item.
  for_each = local.rules_map

  # The name of the Gateway Security Policy rule.
  name = each.value.name

  # A free-text description of the rule.
  description = each.value.description

  # Whether the rule is enabled.
  enabled = each.value.enabled

  # The priority of the rule. Lower numbers have higher precedence.
  priority = each.value.priority

  # The basic profile for the rule, which can be 'ALLOW' or 'DENY'.
  basic_profile = each.value.basic_profile

  # A CEL expression for session-based matching (e.g., 'host() == "example.com"').
  session_matcher = each.value.session_matcher

  # A CEL expression for application-layer matching, required for TLS inspection.
  application_matcher = each.value.application_matcher

  # Flag to enable TLS inspection for traffic that matches this rule.
  tls_inspection_enabled = each.value.tls_inspection_enabled

  # The name of the parent Gateway Security Policy.
  gateway_security_policy = google_network_security_gateway_security_policy.default.name

  # The ID of the project in which the resource belongs. If not set, the provider project will be used.
  project = var.project_id

  # The location of the gateway security policy rule. Must be 'global'.
  location = "global"
}
