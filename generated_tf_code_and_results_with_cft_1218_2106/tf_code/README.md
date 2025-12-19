# Google Secure Web Proxy Module

This module provides a comprehensive way to manage Google Cloud Secure Web Proxy (SWP) resources. It allows you to create a Gateway Security Policy, define a set of rules for traffic filtering, and optionally create a Certificate Authority (CA) Pool for TLS inspection.

## Usage

Here is a basic example of how to use this module to create a Secure Web Proxy policy with a couple of rules and a new CA Pool for TLS inspection.

```terraform
module "secure_web_proxy_policy" {
  source      = "./" // Replace with the actual module source
  project_id  = "your-gcp-project-id"
  name        = "my-swp-policy"
  description = "A sample SWP policy managed by Terraform."

  # Enable creation of a new CA Pool for TLS inspection
  create_tls_inspection_ca_pool = true
  ca_pool_config = {
    name     = "my-swp-ca-pool"
    location = "us-central1"
    tier     = "DEVOPS"
  }

  rules = [
    {
      name        = "deny-social-media"
      description = "Deny access to specific social media sites."
      priority    = 100
      enabled     = true
      basic_profile = "DENY"
      session_matcher = "true" // Match all sessions
      application_matcher = [
        "*.facebook.com",
        "*.twitter.com"
      ]
    },
    {
      name                   = "allow-and-inspect-all"
      description            = "Allow and inspect all other traffic."
      priority               = 1000
      enabled                = true
      basic_profile          = "ALLOW"
      session_matcher        = "true" // Match all sessions
      tls_inspection_enabled = true
    }
  ]
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 5.10.0 |

### APIs

This module will enable the following Google Cloud APIs if they are not already enabled:
*   `networksecurity.googleapis.com`
*   `privateca.googleapis.com`

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | >= 5.10.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_network_security_gateway_security_policy.default](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/network_security_gateway_security_policy) | resource |
| [google_network_security_gateway_security_policy_rule.default](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/network_security_gateway_security_policy_rule) | resource |
| [google_privateca_ca_pool.swp_ca_pool](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/privateca_ca_pool) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ca_pool_config"></a> [ca\_pool\_config](#input\_ca\_pool\_config) | Configuration for the CA Pool to be created if 'create\_tls\_inspection\_ca\_pool' is true. | <pre>object({<br>    name     = string<br>    location = string<br>    tier     = string<br>  })</pre> | <pre>{<br>  "location": "us-central1",<br>  "name": "swp-tls-inspection-pool",<br>  "tier": "DEVOPS"<br>}</pre> | no |
| <a name="input_create_tls_inspection_ca_pool"></a> [create\_tls\_inspection\_ca\_pool](#input\_create\_tls\_inspection\_ca\_pool) | If true, a new Certificate Authority (CA) Pool will be created for TLS inspection. If false, you can provide an existing CA Pool ID via 'tls\_inspection\_ca\_pool\_id'. | `bool` | `false` | no |
| <a name="input_description"></a> [description](#input\_description) | An optional description of this Gateway Security Policy. | `string` | `"Secure Web Proxy policy managed by Terraform."` | no |
| <a name="input_location"></a> [location](#input\_location) | The location for the Gateway Security Policy. This must be 'global'. | `string` | `"global"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name for the Gateway Security Policy. If null, no resources will be created. | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The project ID to deploy the Secure Web Proxy resources in. If null, no resources will be created. | `string` | `null` | no |
| <a name="input_rules"></a> [rules](#input\_rules) | A list of rule objects to create for the Gateway Security Policy. | <pre>list(object({<br>    name                   = string<br>    description            = optional(string, "Terraform-managed SWP rule.")<br>    enabled                = optional(bool, true)<br>    priority               = number<br>    basic_profile          = string<br>    session_matcher        = string<br>    application_matcher    = optional(list(string), [])<br>    tls_inspection_enabled = optional(bool, false)<br>  }))</pre> | `[]` | no |
| <a name="input_tls_inspection_ca_pool_id"></a> [tls\_inspection\_ca\_pool\_id](#input\_tls\_inspection\_ca\_pool\_id) | The resource ID of an existing CA Pool to use for TLS inspection. This is used only when 'create\_tls\_inspection\_ca\_pool' is false. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ca_pool_id"></a> [ca\_pool\_id](#output\_ca\_pool\_id) | The ID of the CA Pool created for TLS inspection, if any. |
| <a name="output_gateway_security_policy_id"></a> [gateway\_security\_policy\_id](#output\_gateway\_security\_policy\_id) | The fully qualified ID of the Gateway Security Policy. |
| <a name="output_gateway_security_policy_name"></a> [gateway\_security\_policy\_name](#output\_gateway\_security\_policy\_name) | The name of the Gateway Security Policy. |
| <a name="output_gateway_security_policy_rules"></a> [gateway\_security\_policy\_rules](#output\_gateway\_security\_policy\_rules) | A map of the created Gateway Security Policy Rules, keyed by rule name. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for information on contributing to this module.
