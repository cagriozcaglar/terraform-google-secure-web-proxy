output "gateway_id" {
  description = "The fully qualified identifier for the Secure Web Proxy gateway."
  value       = try(google_network_services_gateway.main[0].id, null)
}

output "gateway_name" {
  description = "The name of the Secure Web Proxy gateway."
  value       = try(google_network_services_gateway.main[0].name, null)
}

output "policy_id" {
  description = "The fully qualified identifier for the gateway security policy."
  value       = try(google_network_security_gateway_security_policy.main[0].id, null)
}

output "policy_name" {
  description = "The name of the gateway security policy."
  value       = try(google_network_security_gateway_security_policy.main[0].name, null)
}

output "rule_ids" {
  description = "A map of the security policy rule names to their fully qualified identifiers."
  value       = { for k, v in google_network_security_gateway_security_policy_rule.main : k => v.id }
}
