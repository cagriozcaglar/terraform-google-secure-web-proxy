output "gateway_id" {
  description = "The fully qualified ID of the created Secure Web Proxy gateway."
  value       = one(google_network_services_gateway.main[*].id)
}

output "gateway_name" {
  description = "The name of the created Secure Web Proxy gateway."
  value       = one(google_network_services_gateway.main[*].name)
}

output "policy_id" {
  description = "The fully qualified ID of the associated Secure Web Proxy security policy."
  value       = one(google_network_security_gateway_security_policy.main[*].id)
}

output "policy_name" {
  description = "The name of the associated Secure Web Proxy security policy."
  value       = one(google_network_security_gateway_security_policy.main[*].name)
}
