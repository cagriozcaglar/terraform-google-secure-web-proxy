output "gateway_id" {
  description = "The fully qualified ID of the Secure Web Proxy gateway."
  value       = local.enabled ? google_network_services_gateway.default[0].id : null
}

output "gateway_name" {
  description = "The name of the Secure Web Proxy gateway."
  value       = local.enabled ? google_network_services_gateway.default[0].name : null
}

output "security_policy_id" {
  description = "The fully qualified ID of the Secure Web Proxy security policy."
  value       = local.enabled ? google_network_security_gateway_security_policy.default[0].id : null
}

output "security_policy_name" {
  description = "The name of the Secure Web Proxy security policy."
  value       = local.enabled ? google_network_security_gateway_security_policy.default[0].name : null
}

output "tls_inspection_policy_id" {
  description = "The ID of the created TLS Inspection Policy. This will be null if no CA pool was provided or the module was disabled."
  value       = local.enabled && var.ca_pool != null ? google_network_security_tls_inspection_policy.default[0].id : null
}
