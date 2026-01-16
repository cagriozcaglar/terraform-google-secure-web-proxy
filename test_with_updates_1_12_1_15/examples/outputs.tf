# This file declares the outputs that are exposed from the example.

output "gateway_id" {
  description = "The fully qualified identifier for the Secure Web Proxy gateway."
  value       = module.secure_web_proxy.gateway_id
}

output "gateway_name" {
  description = "The name of the Secure Web Proxy gateway."
  value       = module.secure_web_proxy.gateway_name
}

output "policy_id" {
  description = "The fully qualified identifier for the gateway security policy."
  value       = module.secure_web_proxy.policy_id
}

output "policy_name" {
  description = "The name of the gateway security policy."
  value       = module.secure_web_proxy.policy_name
}

output "rule_ids" {
  description = "A map of the security policy rule names to their fully qualified identifiers."
  value       = module.secure_web_proxy.rule_ids
}
