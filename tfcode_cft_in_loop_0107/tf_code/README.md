# Google Cloud Secure Web Proxy Module

This module handles the deployment and configuration of a Google Cloud Secure Web Proxy (SWP) instance. It simplifies the creation of the core SWP components, including the **Gateway**, **Security Policy** with rules, and an optional **TLS Inspection Policy**.

Key features include:
*   Dynamic creation of security policy rules from a list of objects.
*   Conditional creation of a TLS Inspection Policy when a Certificate Authority Service pool is provided.
*   Safe "no-op" behavior where no resources are created if essential variables (`name` and `network`) are omitted.

## Usage

### Basic Example

This example creates a Secure Web Proxy gateway with a security policy that allows traffic to `www.google.com` and denies all other traffic.

```terraform
module "secure_web_proxy" {
  source = "./" # Or your module source

  project_id = "your-gcp-project-id"
  region     = "us-central1"
  name       = "my-swp-instance"
  network    = "projects/your-gcp-project-id/global/networks/my-vpc"

  security_policy_rules = [
    {
      name            = "allow-google"
      priority        = 100
      session_matcher = "host() == 'www.google.com'"
      basic_profile   = "ALLOW"
    },
    {
      name            = "default-deny"
      priority        = 999
      session_matcher = "true" # Matches all sessions
      basic_profile   = "DENY"
    }
  ]

  labels = {
    environment = "dev"
  }
}
```

### TLS Inspection Example

This example creates a Secure Web Proxy gateway with a TLS Inspection Policy to decrypt and inspect traffic to `github.com`. This requires a pre-existing Certificate Authority Service pool.

```terraform
module "secure_web_proxy_tls" {
  source = "./" # Or your module source

  project_id = "your-gcp-project-id"
  region     = "us-central1"
  name       = "my-swp-instance-tls"
  network    = "projects/your-gcp-project-id/global/networks/my-vpc"

  # A CA Pool is required for any rule with tls_inspection_enabled = true
  ca_pool = "projects/your-gcp-project-id/locations/us-central1/caPools/my-ca-pool"

  security_policy_rules = [
    {
      name                   = "inspect-and-allow-github"
      priority               = 100
      session_matcher        = "host() == 'github.com'"
      basic_profile          = "ALLOW"
      tls_inspection_enabled = true
    },
    {
      name            = "default-deny"
      priority        = 999
      session_matcher = "true" # Matches all sessions
      basic_profile   = "DENY"
    }
  ]
}
```

## Requirements

Before this module can be used on a project, you must ensure that the following prerequisites are met:

1.  A pre-existing VPC network.
2.  A [proxy-only subnet](https://cloud.google.com/load-balancing/docs/proxy-only-subnets) must be configured in the specified VPC network and region.

### APIs

A project with the following APIs enabled is required:

*   Network Services API (`networkservices.googleapis.com`)
*   Network Security API (`networksecurity.googleapis.com`)
*   Certificate Authority Service API (`privateca.googleapis.com`) (if using TLS inspection)

### Terraform

-   **Terraform** `~> 1.5`
-   **Google Provider** `~> 5.13`

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | A unique name for the Secure Web Proxy gateway and its associated resources. If not provided, no resources will be created. | `string` | `null` | yes |
| `network` | The self-link of the VPC network to which the Secure Web Proxy gateway is attached. A proxy-only subnetwork must exist in this network and region for the gateway to function. If not provided, no resources will be created. | `string` | `null` | yes |
| `security_policy_rules` | A list of security policy rules to be created and attached to the gateway. Rules are evaluated in order of priority, from lowest to highest.<pre>Each rule object has the following fields:<br>- `name`: (string) A unique name for the rule.<br>- `description`: (string, optional) A description for the rule. Defaults to 'Managed by Terraform'.<br>- `enabled`: (bool, optional) Whether the rule is enabled. Defaults to `true`.<br>- `priority`: (number) The priority of the rule, from 0 to 999. Lower numbers have higher precedence.<br>- `session_matcher`: (string) A CEL expression for session matching. For example, `host() == 'example.com'`.<br>- `application_matcher`: (string, optional) A CEL expression for application matching. Defaults to `true`.<br>- `basic_profile`: (string) The basic profile action. Must be 'ALLOW' or 'DENY'.<br>- `tls_inspection_enabled`: (bool, optional) Whether to enable TLS inspection for this rule. Defaults to `false`. Requires `ca_pool` to be set on the module.</pre> | <pre>list(object({<br>    name                   = string<br>    description            = optional(string, "Managed by Terraform")<br>    enabled                = optional(bool, true)<br>    priority               = number<br>    session_matcher        = string<br>    application_matcher    = optional(string, "true")<br>    basic_profile          = string<br>    tls_inspection_enabled = optional(bool, false)<br>  }))</pre> | `[]` | no |
| `ca_pool` | The resource ID of the Certificate Authority Service CA Pool to use for TLS inspection. If set, a TLS inspection policy will be created and associated with the gateway security policy. Format 'projects/{project}/locations/{location}/caPools/{ca\_pool}'. | `string` | `null` | no |
| `labels` | A map of labels to apply to the gateway resource. | `map(string)` | `{}` | no |
| `ports` | A list of ports that the gateway will listen on. | `list(number)` | `[443]` | no |
| `project_id` | The project ID to deploy the Secure Web Proxy resources in. If not provided, the provider project is used. | `string` | `null` | no |
| `region` | The region to deploy the Secure Web Proxy resources in. If not provided, the provider region is used. | `string` | `null` | no |
| `scope` | A scope defines context for the gateway. If not provided, the gateway name will be used as the scope. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| `gateway_id` | The fully qualified ID of the Secure Web Proxy gateway. |
| `gateway_name` | The name of the Secure Web Proxy gateway. |
| `security_policy_id` | The fully qualified ID of the Secure Web Proxy security policy. |
| `security_policy_name` | The name of the Secure Web Proxy security policy. |
| `tls_inspection_policy_id` | The ID of the created TLS Inspection Policy. This will be null if no CA pool was provided or the module was disabled. |
