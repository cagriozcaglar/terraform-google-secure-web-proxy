# This policy acts as a container for the traffic filtering rules.
resource "google_secure_web_proxy_gateway_policy" "this" {
  # The name of the gateway policy.
  name = "${var.name}-policy"
  # The project in which the resource belongs.
  project = var.project_id
  # The location of the gateway policy.
  location = var.location
  # An optional description of this resource.
  description = var.policy_description
  # The labels associated with this resource.
  labels = var.labels
}

# These are the individual rules that define the filtering logic within the policy.
# A for_each loop is used to create a resource for each object in the `var.policy_rules` list.
resource "google_secure_web_proxy_gateway_policy_rule" "this" {
  for_each = { for rule in var.policy_rules : rule.name => rule }

  # The name of the gateway policy rule.
  name = each.value.name
  # The project in which the resource belongs. If not provided, the provider project is used.
  project = var.project_id
  # The location of the gateway policy rule.
  location = var.location
  # The full self-link of the policy this rule belongs to.
  policy = google_secure_web_proxy_gateway_policy.this.self_link
  # Whether the rule is enforced.
  enabled = each.value.enabled
  # An optional description of this resource.
  description = each.value.description
  # Priority of the rule. Lower number = higher priority.
  priority = each.value.priority
  # The action to take. Can be 'ALLOW' or 'DENY'.
  action = each.value.action
  # A CEL expression that describes the traffic to which this rule applies.
  session_matcher = each.value.session_matcher
  # If true, the TLS connection is terminated and inspected.
  # This requires a `certificate_manager_certificate` to be configured on the gateway.
  tls_inspected = each.value.tls_inspected
}

# This is the Secure Web Proxy gateway instance.
# It is deployed into a specific subnet, attached to a policy, and handles the traffic.
resource "google_secure_web_proxy_gateway" "this" {
  # The name of the gateway.
  name = var.name
  # The project in which the resource belongs.
  project = var.project_id
  # The location of the gateway.
  location = var.location
  # The network that the gateway is attached to.
  network = var.network
  # The subnet that the gateway is attached to.
  subnet = var.subnet
  # The policy that the gateway will enforce.
  policy = google_secure_web_proxy_gateway_policy.this.self_link
  # The type of the gateway.
  type = "SECURE_WEB_GATEWAY"
  # The IP address of the gateway. If not specified, an IP is automatically allocated.
  ip_address = var.ip_address
  # The Certificate Manager certificate to use for TLS inspection.
  certificate_manager_certificate = var.certificate_manager_certificate
  # The labels associated with this resource.
  labels = var.labels

  # The policy and its rules must be created before the gateway can be attached to it.
  depends_on = [
    google_secure_web_proxy_gateway_policy_rule.this
  ]
}
