# The ID of the created Gateway Security Policy.
output "gateway_security_policy_id" {
  description = "The fully qualified ID of the Gateway Security Policy."
  value       = try(google_network_security_gateway_security_policy.default[0].id, null)
}

# The name of the created Gateway Security Policy.
output "gateway_security_policy_name" {
  description = "The name of the Gateway Security Policy."
  value       = try(google_network_security_gateway_security_policy.default[0].name, null)
}

# A map of the created Gateway Security Policy Rules.
output "gateway_security_policy_rules" {
  description = "A map of the created Gateway Security Policy Rules, keyed by rule name."
  value = {
    for k, v in google_network_security_gateway_security_policy_rule.default : k => {
      id   = v.id
      name = v.name
    }
  }
}

# The ID of the Certificate Authority (CA) Pool created for TLS inspection.
output "ca_pool_id" {
  description = "The ID of the CA Pool created for TLS inspection, if any."
  value       = try(google_privateca_ca_pool.swp_ca_pool[0].id, null)
}
