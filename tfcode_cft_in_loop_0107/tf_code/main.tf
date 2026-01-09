# The main.tf file contains the core logic for creating the Secure Web Proxy resources.
locals {
  # A boolean flag to enable/disable the creation of all resources.
  # This allows the module to be "plannable" without required inputs, which is useful for testing and CI/CD.
  # Resources will only be created if both a name and a network are provided.
  enabled = var.name != null && var.network != null

  # Construct resource names from the base name variable for consistency.
  # These are conditionally defined to avoid errors when var.name is null.
  gateway_name = local.enabled ? "${var.name}-gateway" : null
  policy_name  = local.enabled ? "${var.name}-policy" : null

  # Transform the list of rule objects into a map, keyed by rule name.
  # This is necessary to use for_each with the google_network_security_gateway_security_policy_rule resource,
  # allowing for dynamic creation and management of rules.
  rules_map = { for rule in var.security_policy_rules : rule.name => rule }
}

# This check validates that a CA pool is provided if any security rule has TLS inspection enabled.
# This prevents a common misconfiguration where TLS inspection is requested without the necessary certificate infrastructure.
check "tls_inspection_requires_ca_pool" {
  assert {
    # The condition is true if either:
    # 1. No rules have TLS inspection enabled (the anytrue function returns false).
    # 2. A CA pool is provided (var.ca_pool is not null).
    condition     = !anytrue([for r in var.security_policy_rules : r.tls_inspection_enabled]) || var.ca_pool != null
    # The error message to display if the condition is false, guiding the user to the correct configuration.
    error_message = "The 'ca_pool' variable must be set if any security rule has 'tls_inspection_enabled' set to true."
  }
}

# Creates the TLS Inspection Policy, which is required to decrypt and inspect TLS traffic.
# This resource is created conditionally based on the presence of a CA Pool and if the module is enabled.
resource "google_network_security_tls_inspection_policy" "default" {
  # The count meta-argument creates this resource only if the module is enabled and a CA Pool is provided.
  # If local.enabled is false or var.ca_pool is null, count is 0, and the resource is not created.
  count = local.enabled && var.ca_pool != null ? 1 : 0

  # The project ID where the TLS inspection policy will be created. Defaults to the provider's project.
  project = var.project_id
  # A unique name for the TLS inspection policy.
  name = "${local.policy_name}-tls"
  # The location (region) for the policy. Must match the gateway's region. Defaults to the provider's region.
  location = var.region
  # The Certificate Authority Service Pool to use for generating certificates for TLS inspection.
  ca_pool = var.ca_pool
}

# Creates the Secure Web Proxy Security Policy, which acts as a container for security rules.
resource "google_network_security_gateway_security_policy" "default" {
  # This resource is only created if the module is enabled (name and network are provided).
  count = local.enabled ? 1 : 0

  # The project ID where the security policy will be created. Defaults to the provider's project.
  project = var.project_id
  # The name of the security policy.
  name = local.policy_name
  # The location (region) for the security policy. Must match the gateway's region. Defaults to the provider's region.
  location = var.region
  # The TLS inspection policy to attach. This enables TLS inspection for rules that have it enabled.
  # This is conditionally attached only if a CA pool is provided.
  tls_inspection_policy = var.ca_pool != null ? google_network_security_tls_inspection_policy.default[0].id : null
}

# Creates the individual rules for the Secure Web Proxy Security Policy.
# These resources are created dynamically based on the `security_policy_rules` input variable.
resource "google_network_security_gateway_security_policy_rule" "default" {
  # Iterates over the map of rules if the module is enabled, otherwise iterates over an empty map.
  for_each = local.enabled ? local.rules_map : {}

  # The project ID where the rule will be created. Inherits from the parent policy.
  project = google_network_security_gateway_security_policy.default[0].project
  # The location (region) for the rule. Inherits from the parent policy.
  location = google_network_security_gateway_security_policy.default[0].location
  # The name of the parent security policy.
  gateway_security_policy = google_network_security_gateway_security_policy.default[0].name
  # The name of the rule, from the loop's key.
  name = each.value.name
  # An optional description for the rule.
  description = each.value.description
  # Determines if the rule is active.
  enabled = each.value.enabled
  # The priority of the rule (0-999), used for evaluation order. Lower numbers have higher precedence.
  priority = each.value.priority
  # The CEL expression for matching traffic based on session attributes (e.g., source/destination IP, host).
  session_matcher = each.value.session_matcher
  # The CEL expression for matching traffic based on application attributes (e.g., request headers).
  application_matcher = each.value.application_matcher
  # The action to take for matching traffic, either 'ALLOW' or 'DENY'.
  basic_profile = each.value.basic_profile
  # Determines whether to enable TLS inspection for matching sessions.
  tls_inspection_enabled = each.value.tls_inspection_enabled
}

# Creates the Secure Web Proxy Gateway instance.
# This is the core proxy that intercepts traffic and enforces the attached security policy.
resource "google_network_services_gateway" "default" {
  # This resource is only created if the module is enabled (name and network are provided).
  count = local.enabled ? 1 : 0

  # The project ID where the gateway will be created. Defaults to the provider's project.
  project = var.project_id
  # The name of the gateway.
  name = local.gateway_name
  # The location (region) for the gateway. Defaults to the provider's region.
  location = var.region
  # The type of the gateway. Must be SECURE_WEB_GATEWAY for this use case.
  type = "SECURE_WEB_GATEWAY"
  # A list of ports that the gateway will listen on.
  ports = var.ports
  # The VPC network to which the gateway is attached.
  network = var.network
  # A scope that defines a unique FQDN for the gateway. Defaults to the gateway name.
  scope = coalesce(var.scope, local.gateway_name)
  # The ID of the security policy to attach to the gateway.
  gateway_security_policy = google_network_security_gateway_security_policy.default[0].id
  # The labels to apply to the gateway.
  labels = var.labels

  # Explicitly depend on the policy rules to ensure they are created before the gateway.
  # This prevents potential errors where the gateway is created before its policy is fully configured.
  depends_on = [
    google_network_security_gateway_security_policy_rule.default
  ]
}
