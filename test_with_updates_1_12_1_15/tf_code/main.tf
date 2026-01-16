# The locals block is used to define local variables within the module.
locals {
  # If name or network is not provided, disable the creation of resources.
  enabled = var.name != null && var.network != null

  # Use provided project_id, otherwise fall back to the provider's project.
  project_id = var.project_id == null ? data.google_client_config.default.project : var.project_id
  # Use provided region, otherwise fall back to the provider's region.
  region = var.region == null ? data.google_client_config.default.region : var.region

  # Concatenates the user-provided name with a standard suffix for the policy.
  policy_name = local.enabled ? "${var.name}-policy" : null
  # Concatenates the user-provided name with a standard suffix for the gateway.
  gateway_name = local.enabled ? "${var.name}-gateway" : null
}

# This data source retrieves the default client configuration for the Google provider.
data "google_client_config" "default" {}

# This resource defines the security policy, which acts as a container for all the rules.
resource "google_network_security_gateway_security_policy" "main" {
  # Controls the creation of the resource based on the presence of required variables.
  count = local.enabled ? 1 : 0

  # The project ID where the security policy will be created.
  project = local.project_id
  # The name of the security policy.
  name = local.policy_name
  # The location of the security policy. Secure Web Proxy policies are always global.
  location = "global"
  # An optional description for the security policy.
  description = var.policy_description

  # The ID of a Certificate Manager certificate for TLS inspection. This is set only if a value is provided.
  tls_inspection_policy = var.tls_inspection_policy_certificate_id
}

# This resource creates a security policy rule for each object defined in the 'rules' variable.
resource "google_network_security_gateway_security_policy_rule" "main" {
  # Creates one rule resource for each item in the var.rules list if the module is enabled.
  for_each = local.enabled ? { for rule in var.rules : rule.name => rule } : {}

  # The project ID where the rule will be created.
  project = google_network_security_gateway_security_policy.main[0].project
  # The location of the rule, which is always global.
  location = google_network_security_gateway_security_policy.main[0].location
  # The name of the parent security policy.
  gateway_security_policy = google_network_security_gateway_security_policy.main[0].name
  # The name of the rule.
  name = each.value.name
  # An optional description for the rule.
  description = each.value.description
  # Whether the rule is enabled.
  enabled = each.value.enabled
  # The priority of the rule, used to determine the order of evaluation.
  priority = each.value.priority
  # The CEL expression for matching sessions.
  session_matcher = each.value.session_matcher
  # The CEL expression for matching applications.
  application_matcher = each.value.application_matcher
  # The basic action to take, either 'ALLOW' or 'DENY'.
  basic_profile = each.value.basic_profile
  # Whether to enable TLS inspection for traffic that matches this rule.
  tls_inspection_enabled = each.value.tls_inspection_enabled
}

# This resource creates the Secure Web Proxy gateway, the data plane component that enforces the policy.
resource "google_network_services_gateway" "main" {
  # Controls the creation of the resource based on the presence of required variables.
  count = local.enabled ? 1 : 0

  # The project ID where the gateway will be created.
  project = local.project_id
  # The name of the gateway.
  name = local.gateway_name
  # The GCP region where the gateway will be located.
  location = local.region
  # The self-link of the VPC network to which this gateway is attached.
  network = var.network
  # The list of ports on which the Gateway will receive traffic.
  ports = var.gateway_ports
  # The type of the gateway.
  type = "SECURE_WEB_GATEWAY"
  # A user-defined scope name for the gateway.
  scope = var.scope
  # An optional description for the gateway.
  description = var.gateway_description
  # Labels to apply to the gateway resource.
  labels = var.labels

  # Attaches the security policy to the gateway.
  gateway_security_policy = google_network_security_gateway_security_policy.main[0].id
}
