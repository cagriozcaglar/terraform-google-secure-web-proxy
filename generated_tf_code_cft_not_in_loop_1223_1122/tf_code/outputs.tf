# The full ID of the Secure Web Proxy gateway.
output "gateway_id" {
  description = "The full ID of the Secure Web Proxy gateway."
  value       = google_secure_web_proxy_gateway.this.id
}

# The name of the Secure Web Proxy gateway.
output "gateway_name" {
  description = "The name of the Secure Web Proxy gateway."
  value       = google_secure_web_proxy_gateway.this.name
}

# The full ID of the Secure Web Proxy policy.
output "policy_id" {
  description = "The full ID of the Secure Web Proxy policy."
  value       = google_secure_web_proxy_gateway_policy.this.id
}

# The name of the Secure Web Proxy policy.
output "policy_name" {
  description = "The name of the Secure Web Proxy policy."
  value       = google_secure_web_proxy_gateway_policy.this.name
}
