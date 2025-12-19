# The outputs.tf file defines the outputs of the module.
output "gateway_id" {
  description = "The unique identifier of the created Secure Web Proxy gateway."
  value       = local.enabled ? google_network_services_gateway.main[0].id : null
}

output "gateway_name" {
  description = "The name of the created Secure Web Proxy gateway."
  value       = local.enabled ? google_network_services_gateway.main[0].name : null
}

output "gateway_self_link" {
  description = "The self-link of the created Secure Web Proxy gateway."
  value       = local.enabled ? google_network_services_gateway.main[0].self_link : null
}

output "policy_id" {
  description = "The unique identifier of the created Gateway Security Policy."
  value       = local.enabled ? google_network_security_gateway_security_policy.main[0].id : null
}

output "policy_name" {
  description = "The name of the created Gateway Security Policy."
  value       = local.enabled ? google_network_security_gateway_security_policy.main[0].name : null
}

output "rule_names" {
  description = "A list of the names of the security policy rules that were created."
  value       = local.enabled ? keys(google_network_security_gateway_security_policy_rule.main) : []
}
