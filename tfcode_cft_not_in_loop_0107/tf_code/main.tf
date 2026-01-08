# The Secure Web Proxy Gateway instance itself, provided by the Network Services API.
resource "google_network_services_gateway" "main" {
  # Add a count to conditionally create the resource based on input variables.
  count = local.create_resources ? 1 : 0

  # The name of the Secure Web Proxy gateway.
  name = "${var.name}-gateway"
  # The project ID where the gateway will be created.
  project = local.project_id
  # The location (region) for the gateway.
  location = local.location
  # The type of the gateway.
  type = "SECURE_WEB_GATEWAY"
  # A list of ports to which this gateway is bound.
  ports = var.ports
  # The self-link of the network to which this gateway is attached.
  network = var.network
  # The self-link of the proxy-only subnet to which this gateway is attached.
  subnetwork = var.subnet
  # The resource URL of the security policy to apply to this gateway's traffic.
  gateway_security_policy = one(google_network_security_gateway_security_policy.main[*].id)
}

# The Gateway Security Policy, which acts as a container for rules.
resource "google_network_security_gateway_security_policy" "main" {
  # Add a count to conditionally create the resource based on input variables.
  count = local.create_resources ? 1 : 0

  # The name of the security policy.
  name = "${var.name}-policy"
  # The project ID where the security policy will be created.
  project = local.project_id
  # The location (region) for the security policy.
  location = local.location
  # The self-link of the TLS inspection policy, if any.
  tls_inspection_policy = var.tls_inspection_policy
}

# The security policy rules that define the access control logic.
# A resource is created for each rule defined in the 'var.rules' input variable.
resource "google_network_security_gateway_security_policy_rule" "main" {
  # Creates one rule resource for each object in the var.rules list, only if the parent policy is being created.
  # The rule's 'name' field is used as the unique key.
  for_each = local.create_resources ? { for rule in var.rules : rule.name => rule } : {}

  # The unique name for the rule.
  name = each.value.name
  # The project ID where the rule will be created.
  project = local.project_id
  # The location (region) for the rule, which must match its parent policy.
  location = local.location
  # The name of the parent security policy.
  gateway_security_policy = one(google_network_security_gateway_security_policy.main[*].name)
  # A user-provided description for the rule.
  description = each.value.description
  # Whether the rule is enabled or disabled.
  enabled = each.value.enabled
  # The priority of the rule, with lower numbers being evaluated first.
  priority = each.value.priority
  # The CEL expression to match session criteria (e.g., source IP, tags).
  session_matcher = each.value.session_matcher
  # The CEL expression to match application-layer criteria (e.g., request host).
  application_matcher = each.value.application_matcher
  # The action to take on matched traffic, either 'ALLOW' or 'DENY'.
  basic_profile = each.value.basic_profile
}

data "google_client_config" "current" {}

locals {
  # Determine if the required variables are set to decide whether to create resources.
  create_resources = var.name != null && var.network != null && var.subnet != null
  # Use the provided project_id or fall back to the provider's project.
  project_id = var.project_id == null ? data.google_client_config.current.project : var.project_id
  # Use the provided location or fall back to the provider's region.
  location = var.location == null ? data.google_client_config.current.region : var.location
}
