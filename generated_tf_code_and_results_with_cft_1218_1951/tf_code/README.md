# Terraform Google Secure Web Proxy Module

This module makes it easy to set up a Google Cloud Secure Web Proxy (SWP) instance, including the gateway, security policy, and associated rules.

Secure Web Proxy is a cloud-native service that helps you secure your web outbound traffic. You can enforce granular access policies based on web service identities, and you can audit all traffic in and out of your network for security threats.

This module creates the following resources:
- A Secure Web Proxy Gateway instance (`google_network_services_gateway`).
- A Gateway Security Policy (`google_network_security_gateway_security_policy`).
- A set of Gateway Security Policy Rules (`google_network_security_gateway_security_policy_rule`).

## Usage

Basic usage of this module is as follows:

```hcl
module "secure_web_proxy" {
  source = "./" # Replace with the actual source path

  project_id = "your-gcp-project-id"
  name       = "my-swp-instance"
  location   = "us-central1"
  network    = "projects/your-gcp-project-id/global/networks/my-vpc"
  subnetwork = "projects/your-gcp-project-id/regions/us-central1/subnetworks/my-proxy-only-subnet"

  # Optional: Define security rules
  rules = [
    {
      name          = "allow-google-apis"
      description   = "Allow all traffic to Google APIs."
      enabled       = true
      priority      = 100
      basic_profile = "ALLOW"
      session_matcher = "host() == 'googleapis.com'"
    },
    {
      name          = "deny-all"
      description   = "Default deny for all other traffic."
      enabled       = true
      priority      = 1000
      basic_profile = "DENY"
      session_matcher = "true"
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the Google Cloud project where the resources will be created. If not provided, no resources will be created. | `string` | `null` | yes |
| <a name="input_name"></a> [name](#input\_name) | A base name for the Secure Web Proxy resources, which will be used to name the gateway and security policy. If not provided, no resources will be created. | `string` | `null` | yes |
| <a name="input_location"></a> [location](#input\_location) | The Google Cloud region where the Secure Web Proxy gateway will be deployed. If not provided, no resources will be created. | `string` | `null` | yes |
| <a name="input_network"></a> [network](#input\_network) | The self-link of the VPC network to which the gateway is attached. If not provided, no resources will be created. | `string` | `null` | yes |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | The self-link of the subnet to which the gateway is attached. This subnet must be a proxy-only subnet. If not provided, no resources will be created. | `string` | `null` | yes |
| <a name="input_rules"></a> [rules](#input\_rules) | A list of objects representing the security policy rules to create. `priority` is a number between 1 and 1000, where lower numbers indicate higher precedence. `basic_profile` must be one of 'ALLOW' or 'DENY'. `session_matcher` and `application_matcher` use Common Expression Language (CEL). | <pre>list(object({<br>    name                   = string<br>    description            = optional(string)<br>    enabled                = optional(bool, true)<br>    priority               = number<br>    basic_profile          = string<br>    session_matcher        = string<br>    application_matcher    = optional(string)<br>    tls_inspection_enabled = optional(bool)<br>  }))</pre> | `[]` | no |
| <a name="input_gateway_description"></a> [gateway\_description](#input\_gateway\_description) | An optional description for the Secure Web Proxy gateway. | `string` | `null` | no |
| <a name="input_policy_description"></a> [policy\_description](#input\_policy\_description) | An optional description for the Gateway Security Policy. | `string` | `null` | no |
| <a name="input_tls_inspection_policy"></a> [tls\_inspection\_policy](#input\_tls\_inspection\_policy) | The resource name of the Certificate Manager CA Pool to use for TLS inspection. Format: `projects/{project}/locations/{location}/caPools/{ca_pool}`. If not set, TLS inspection is disabled for the policy. | `string` | `null` | no |
| <a name="input_scope"></a> [scope](#input\_scope) | A user-defined scope name for the gateway. This is used to organize gateways. | `string` | `"default-scope"` | no |
| <a name="input_ports"></a> [ports](#input\_ports) | A list of ports that the gateway will listen on. Supported ports are 80 and 443. | `list(number)` | `[443]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gateway_id"></a> [gateway\_id](#output\_gateway\_id) | The unique identifier of the created Secure Web Proxy gateway. |
| <a name="output_gateway_name"></a> [gateway\_name](#output\_gateway\_name) | The name of the created Secure Web Proxy gateway. |
| <a name="output_gateway_self_link"></a> [gateway\_self\_link](#output\_gateway\_self\_link) | The self-link of the created Secure Web Proxy gateway. |
| <a name="output_policy_id"></a> [policy\_id](#output\_policy\_id) | The unique identifier of the created Gateway Security Policy. |
| <a name="output_policy_name"></a> [policy\_name](#output\_policy\_name) | The name of the created Gateway Security Policy. |
| <a name="output_rule_names"></a> [rule\_names](#output\_rule\_names) | A list of the names of the security policy rules that were created. |

## Requirements

Before this module can be used on a project, you must ensure that the following APIs are enabled:

- Network Services API: `networkservices.googleapis.com`
- Network Security API: `networksecurity.googleapis.com`
- Compute Engine API: `compute.googleapis.com`
- Certificate Manager API: `certificatemanager.googleapis.com` (if using TLS inspection)

### Terraform

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 5.14 |

## Resources

| Name | Type |
|------|------|
| [google\_network\_security\_gateway\_security\_policy.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/network_security_gateway_security_policy) | resource |
| [google\_network\_security\_gateway\_security\_policy\_rule.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/network_security_gateway_security_policy_rule) | resource |
| [google\_network\_services\_gateway.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/network_services_gateway) | resource |
