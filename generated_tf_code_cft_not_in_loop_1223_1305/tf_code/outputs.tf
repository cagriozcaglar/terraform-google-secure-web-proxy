# The outputs.tf file defines the values that will be exposed by the module.
# The fully qualified ID of the created Gateway Security Policy.
output "policy_id" {
  description = "The fully qualified ID of the Gateway Security Policy."
  value       = google_network_security_gateway_security_policy.default.id
}

# The name of the created Gateway Security Policy.
output "policy_name" {
  description = "The name of the Gateway Security Policy."
  value       = google_network_security_gateway_security_policy.default.name
}

# A map of the created policy rules, with the rule name as the key and the rule ID as the value.
output "rules_map" {
  description = "A map of the created Gateway Security Policy Rules, with rule names as keys and rule IDs as values."
  value       = { for k, v in google_network_security_gateway_security_policy_rule.default : k => v.id }
}
