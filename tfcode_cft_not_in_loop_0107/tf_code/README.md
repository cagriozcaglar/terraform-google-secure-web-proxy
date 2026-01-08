# Terraform Google Secure Web Proxy Module

This module deploys a [Google Cloud Secure Web Proxy](https://cloud.google.com/secure-web-proxy/docs/overview) (SWP) instance, along with an associated security policy and rules. It provides a simple and reusable way to configure secure outbound web access for workloads within a VPC network.

The module creates the following core resources:
- A Secure Web Proxy Gateway instance (`google_network_services_gateway`).
- A Gateway Security Policy (`google_network_security_gateway_security_policy`).
- A set of Gateway Security Policy Rules (`google_network_security_gateway_security_policy_rule`).

## Usage

Here is a basic example of how to use this module:

```hcl
module "secure_web_proxy" {
  source = "./" # Or your module source

  name       = "my-swp-instance"
  project_id = "my-gcp-project-id"
  location   = "us-central1"
  network    = "projects/my-gcp-project-id/global/networks/my-vpc"
  subnet     = "projects/my-gcp-project-id/regions/us-central1/subnetworks/my-proxy-only-subnet"
  ports      = [443]

  rules = [
    {
      name                = "allow-google-apis"
      description         = "Allow access to Google APIs."
      enabled             = true
      priority            = 100
      session_matcher     = "true"
      application_matcher = "request.host.endsWith('.googleapis.com')"
      basic_profile       = "ALLOW"
    },
    {
      name                = "deny-all-else"
      description         = "Deny all other traffic."
      enabled             = true
      priority            = 999
      session_matcher     = "true"
      application_matcher = null
      basic_profile       = "DENY"
    }
  ]
}
```

## Requirements

Before this module can be used on a project, you must ensure that the following APIs are enabled:

-   Network Services API: `networkservices.googleapis.com`
-   Network Security API: `networksecurity.googleapis.com`

The service account or user running Terraform needs the following IAM roles on the specified project:

-   `roles/networkservices.gatewayAdmin`: To create and manage the SWP Gateway.
-   `roles/networksecurity.gatewaySecurityPolicyAdmin`: To create and manage gateway security policies and rules.
-   `roles/compute.networkUser`: To access the specified VPC network and subnetwork.

### Software

The following software is required:

| Name      | Version |
| --------- | ------- |
| Terraform | >= 1.3.0  |
| Google    | ~> 5.14   |

## Inputs

| Name                    | Description                                                                                                                                                             | Type                                                                                                                                           | Default                               | Required |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------- | :------: |
| `name`                  | The base name for the Secure Web Proxy gateway and its associated security policy.                                                                                      | `string`                                                                                                                                       | `null`                                |   yes    |
| `network`               | The self-link of the VPC network to which the Secure Web Proxy is attached. E.g., 'projects/my-project/global/networks/my-network'.                                      | `string`                                                                                                                                       | `null`                                |   yes    |
| `subnet`                | The self-link of the proxy-only subnet to which the Secure Web Proxy is attached. E.g., 'projects/my-project/regions/us-central1/subnetworks/my-proxy-subnet'.            | `string`                                                                                                                                       | `null`                                |   yes    |
| `location`              | The Google Cloud region where the Secure Web Proxy will be deployed. If not provided, the provider's region is used.                                                    | `string`                                                                                                                                       | `null`                                |    no    |
| `ports`                 | A list of ports to which the gateway is bound. The gateway will listen on these ports for incoming traffic.                                                               | `list(number)`                                                                                                                                 | `[443]`                               |    no    |
| `project_id`            | The project ID where the Secure Web Proxy and its components will be deployed. If not provided, the provider project is used.                                            | `string`                                                                                                                                       | `null`                                |    no    |
| `rules`                 | A list of security policy rules to apply to the gateway. Rules are evaluated in order of their 'priority' field, from lowest to highest number. The 'name' of each rule must be unique within the policy. | `list(object({ name = string, description = optional(string), enabled = bool, priority = number, session_matcher = string, application_matcher = optional(string), basic_profile = string }))` | A default rule to allow all traffic |    no    |
| `tls_inspection_policy` | The self-link of an existing TLS Inspection Policy to be attached to the security policy for inspecting encrypted traffic. If set to null, TLS inspection is disabled.   | `string`                                                                                                                                       | `null`                                |    no    |

## Outputs

| Name           | Description                                                                 |
| -------------- | --------------------------------------------------------------------------- |
| `gateway_id`   | The fully qualified ID of the created Secure Web Proxy gateway.             |
| `gateway_name` | The name of the created Secure Web Proxy gateway.                           |
| `policy_id`    | The fully qualified ID of the associated Secure Web Proxy security policy.  |
| `policy_name`  | The name of the associated Secure Web Proxy security policy.                |
