# The main.tf file contains the core logic for creating the Secure Web Proxy resources.
locals {
  # A flag to enable/disable resource creation. Resources are only created if all required variables are provided.
  enabled = var.project_id != null && var.name != null && var.location != null && var.network != null && var.subnetwork != null

  # Generates a name for the security policy based on the user-provided base name.
  policy_name = var.name != null ? "${var.name}-policy" : null
  # Generates a name for the gateway based on the user-provided base name.
  gateway_name = var.name != null ? "${var.name}-gateway" : null
}

# This resource defines the Gateway Security Policy, which acts as a container for traffic filtering rules.
resource "google_network_security_gateway_security_policy" "main" {
  # Create this resource only if all required variables are provided.
  count = local.enabled ? 1 : 0

  # The GCP project ID where the policy will be created.
  project = var.project_id
  # The name of the security policy.
  name = local.policy_name
  # The GCP region for the policy, which must match the gateway's region.
  location = var.location
  # An optional user-provided description for the policy.
  description = var.policy_description
  # The resource name of the Certificate Manager CA Pool to use for TLS inspection.
  tls_inspection_policy = var.tls_inspection_policy
}

# This resource creates a set of security policy rules based on the `var.rules` input variable.
# A `for_each` loop is used to create a resource for each rule object in the list.
resource "google_network_security_gateway_security_policy_rule" "main" {
  # Iterates over the list of rule objects provided in var.rules, creating them only if the parent policy is being created.
  for_each = local.enabled ? { for rule in var.rules : rule.name => rule } : {}

  # The GCP project ID, inherited from the policy.
  project = google_network_security_gateway_security_policy.main[0].project
  # The name of the parent Gateway Security Policy.
  gateway_security_policy = google_network_security_gateway_security_policy.main[0].name
  # The GCP region, inherited from the policy.
  location = google_network_security_gateway_security_policy.main[0].location

  # The unique name for this rule.
  name = each.value.name
  # An optional description for the rule.
  description = each.value.description
  # Whether the rule is active.
  enabled = each.value.enabled
  # The rule's priority (1-1000). Lower numbers have higher precedence.
  priority = each.value.priority
  # The action to take when the rule matches: 'ALLOW' or 'DENY'.
  basic_profile = each.value.basic_profile
  # A CEL expression for matching L4 session attributes (e.g., source IP).
  session_matcher = each.value.session_matcher
  # A CEL expression for matching L7 application attributes (e.g., request host).
  application_matcher = each.value.application_matcher
  # Whether to enable TLS inspection for traffic matching this rule.
  tls_inspection_enabled = each.value.tls_inspection_enabled
}

# This resource creates the Secure Web Proxy gateway instance itself.
resource "google_network_services_gateway" "main" {
  # Create this resource only if all required variables are provided.
  count = local.enabled ? 1 : 0

  # The GCP project ID where the gateway will be created.
  project = var.project_id
  # The name of the gateway instance.
  name = local.gateway_name
  # The GCP region where the gateway will be deployed.
  location = var.location
  # An optional user-provided description for the gateway.
  description = var.gateway_description

  # The type of the gateway. Currently, only 'SECURE_WEB_GATEWAY' is supported.
  type = "SECURE_WEB_GATEWAY"

  # The self-link of the VPC network where the gateway will reside.
  network = var.network
  # The self-link of the proxy-only subnet where the gateway will be deployed.
  subnetwork = var.subnetwork

  # The ID of the Gateway Security Policy to attach to this gateway.
  gateway_security_policy = google_network_security_gateway_security_policy.main[0].id

  # A user-defined scope for organizing gateways.
  scope = var.scope
  # The list of ports the gateway will listen on.
  ports = var.ports
}
