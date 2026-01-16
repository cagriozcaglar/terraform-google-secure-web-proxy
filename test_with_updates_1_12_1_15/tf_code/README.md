# Terraform Module for Google Cloud Secure Web Proxy

This module simplifies the deployment of a [Google Cloud Secure Web Proxy](https://cloud.google.com/secure-web-proxy/docs/overview) instance. It creates a Secure Web Proxy gateway, an associated security policy, and a set of user-defined rules to control outbound web traffic from a VPC network.

The resources created by this module are:
- A `google_network_services_gateway` of type `SECURE_WEB_GATEWAY`.
- A `google_network_security_gateway_security_policy` to contain filtering rules.
- One or more `google_network_security_gateway_security_policy_rule` resources based on the provided `rules` variable.

## Usage

Below is a basic example of how to use the module.

```hcl
module "secure_web_proxy" {
  source = "./path/to/module" # Or a Git source

  project_id = "your-gcp-project-id"
  region     = "us-central1"
  name       = "my-swp-instance"
  network    = "projects/your-gcp-project-id/global/networks/your-vpc-network"

  // Optional: Enable TLS inspection by providing a Certificate Manager certificate
  // tls_inspection_policy_certificate_id = "projects/your-gcp-project-id/locations/global/certificates/my-certificate"

  rules = [
    {
      name            = "allow-google"
      priority        = 100
      enabled         = true
      session_matcher = "host().endsWith('.google.com')"
      basic_profile   = "ALLOW"
    },
    {
      name                   = "allow-and-inspect-example"
      priority               = 200
      enabled                = true
      session_matcher        = "host().endsWith('.example.com')"
      basic_profile          = "ALLOW"
      tls_inspection_enabled = true // Requires tls_inspection_policy_certificate_id to be set
    },
    {
      name            = "deny-all"
      priority        = 1000 // Lowest priority
      enabled         = true
      session_matcher = "true" // Matches all traffic
      basic_profile   = "DENY"
    }
  ]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- Terraform >= 1.3
- Terraform provider for Google Cloud Platform >= 5.13

### APIs

A project with the following APIs enabled is required:

- Network Services API: `networkservices.googleapis.com`
- Network Security API: `networksecurity.googleapis.com`
- Certificate Manager API: `certificatemanager.googleapis.com` (if using `tls_inspection_policy_certificate_id`)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | A unique name to be used as a prefix for the created gateway and security policy resources. If not provided, no resources will be created. | `string` | `null` | yes |
| `network` | The self-link of the VPC network to which the gateway is attached, e.g. projects/PROJECT\_ID/global/networks/NETWORK\_NAME. If not provided, no resources will be created. | `string` | `null` | yes |
| `gateway_description` | A description for the Secure Web Proxy gateway resource. | `string` | `"Secure Web Proxy gateway managed by Terraform."` | no |
| `gateway_ports` | A list of ports (1-65535) on which the gateway will receive traffic. | `list(number)` | `[443]` | no |
| `labels` | A map of key-value pairs to apply as labels to the gateway. | `map(string)` | `{}` | no |
| `policy_description` | A description for the Secure Web Proxy security policy resource. | `string` | `"Secure Web Proxy security policy managed by Terraform."` | no |
| `project_id` | The GCP project ID where the Secure Web Proxy resources will be created. If not provided, the provider project will be used. | `string` | `null` | no |
| `region` | The GCP region where the Secure Web Proxy gateway will be deployed. If not provided, the provider region will be used. | `string` | `null` | no |
| `rules` | A list of security policy rule objects to create. Rules are evaluated in order of priority, from lowest to highest number.<br>Each rule object has the following attributes:<br>- `name` (string): The name of the rule.<br>- `description` (string, optional): A description for the rule. Defaults to 'Managed by Terraform'.<br>- `enabled` (bool, optional): Whether the rule is enabled. Defaults to true.<br>- `priority` (number): The priority of the rule (0-1000). Lower numbers have higher priority.<br>- `session_matcher` (string): A CEL expression to match sessions (e.g., `host().endsWith('.example.com')`).<br>- `application_matcher` (string, optional): A CEL expression to match applications (e.g., `tls=true`).<br>- `basic_profile` (string): The action to take. Must be 'ALLOW' or 'DENY'.<br>- `tls_inspection_enabled` (bool, optional): Whether to enable TLS inspection for traffic matching this rule. Defaults to false. | <pre>list(object({<br>    name                   = string<br>    description            = optional(string, "Managed by Terraform")<br>    enabled                = optional(bool, true)<br>    priority               = number<br>    session_matcher        = string<br>    application_matcher    = optional(string)<br>    basic_profile          = string<br>    tls_inspection_enabled = optional(bool, false)<br>  }))</pre> | `[]` | no |
| `scope` | A user-defined name for the scope of the gateway. This is used to organize gateways. | `string` | `null` | no |
| `tls_inspection_policy_certificate_id` | The self-link of a Certificate Manager certificate to use for TLS inspection. If provided, TLS inspection is enabled on the policy. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| `gateway_id` | The fully qualified identifier for the Secure Web Proxy gateway. |
| `gateway_name` | The name of the Secure Web Proxy gateway. |
| `policy_id` | The fully qualified identifier for the gateway security policy. |
| `policy_name` | The name of the gateway security policy. |
| `rule_ids` | A map of the security policy rule names to their fully qualified identifiers. |

## Resources

| Name | Type |
|------|------|
| [google_network_security_gateway_security_policy.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/network_security_gateway_security_policy) | resource |
| [google_network_security_gateway_security_policy_rule.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/network_security_gateway_security_policy_rule) | resource |
| [google_network_services_gateway.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/network_services_gateway) | resource |
| [google_client_config.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |

<!-- END_TF_DOCS -->
