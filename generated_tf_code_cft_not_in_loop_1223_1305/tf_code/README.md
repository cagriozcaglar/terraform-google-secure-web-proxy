# Google Cloud Gateway Security Policy Terraform Module

This module manages a Google Cloud [Gateway Security Policy](https://cloud.google.com/secure-web-proxy/docs/overview) and its associated rules. Gateway Security Policies are regional resources used with Secure Web Proxy to enforce granular, identity-aware, and secure-by-default access controls for internet-bound traffic.

This module creates a single `google_network_security_gateway_security_policy` and multiple `google_network_security_gateway_security_policy_rule` resources based on the provided inputs.

## Table of Contents

- [Usage](#usage)
- [Requirements](#requirements)
- [Inputs](#inputs)
- [Outputs](#outputs)

## Usage

Below is a basic example of how to use the module to create a Gateway Security Policy with two rules: one to deny access to a specific host and another to allow and inspect traffic to a different host.

```hcl
module "gateway_security_policy" {
  source       = "<path-to-module>"
  project_id   = "your-gcp-project-id"
  policy_name  = "my-secure-web-proxy-policy"
  policy_description  = "Example policy to block social media and allow example.com"

  rules = [
    {
      name                   = "deny-social-media"
      description            = "Deny access to social media sites."
      enabled                = true
      priority               = 100
      basic_profile          = "DENY"
      session_matcher        = "host() == 'facebook.com' || host() == 'twitter.com'"
    },
    {
      name                   = "allow-and-inspect-example"
      description            = "Allow and inspect traffic to example.com"
      enabled                = true
      priority               = 200
      basic_profile          = "ALLOW"
      session_matcher        = "host() == 'example.com'"
      tls_inspection_enabled = true
      application_matcher    = "request.path.contains('/admin')"
    }
  ]
}
```

## Requirements

The following requirements are needed to use this module:

- Terraform `v1.3` or later.
- The [Google Beta Provider](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs) `v4.70.0` or later.
- A Google Cloud project with the following APIs enabled:
  - `networksecurity.googleapis.com`

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `policy_description` | A free-text description of the Gateway Security Policy. | `string` | `"Gateway Security Policy managed by Terraform"` | no |
| `policy_name` | The name of the Gateway Security Policy. | `string` | `"default-gateway-security-policy"` | no |
| `project_id` | The ID of the project in which the resource belongs. If not set, the provider project will be used. | `string` | `null` | no |
| `rules` | A list of rule objects to create for the Gateway Security Policy. Each rule defines a condition and an action (`ALLOW`/`DENY`).<br><br>Each object in the list has the following attributes:<br>- `name` (string): The name of the rule.<br>- `description` (string): A free-text description of the rule.<br>- `enabled` (bool, optional): Whether the rule is enabled. Defaults to `true`.<br>- `priority` (number): The priority of the rule. Lower numbers have higher precedence.<br>- `basic_profile` (string): The basic profile for the rule, which must be either `ALLOW` or `DENY`.<br>- `session_matcher` (string): A CEL expression for session-based matching (e.g., `'host() == "example.com"'`).<br>- `application_matcher` (string, optional): A CEL expression for application-layer matching. Required if `tls_inspection_enabled` is `true`.<br>- `tls_inspection_enabled` (bool, optional): Enables TLS inspection for traffic that matches this rule. Defaults to `false`. | `list(object)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| `policy_id` | The fully qualified ID of the Gateway Security Policy. |
| `policy_name` | The name of the Gateway Security Policy. |
| `rules_map` | A map of the created Gateway Security Policy Rules, with rule names as keys and rule IDs as values. |
