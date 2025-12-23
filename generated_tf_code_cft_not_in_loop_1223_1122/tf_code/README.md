# Secure Web Proxy Module

This Terraform module deploys a [Google Cloud Secure Web Proxy (SWP)](https://cloud.google.com/secure-web-proxy/docs/overview) instance. It creates a SWP gateway, an associated policy, and a set of configurable rules to filter outbound web traffic from your VPC. The module supports features like TLS inspection when provided with a Certificate Manager certificate.

## Usage

Below is a basic example of how to use the module:

```hcl
module "secure_web_proxy" {
  source = "./" # Replace with module source

  project_id = "my-gcp-project-id"
  name       = "my-swp-gateway"
  location   = "us-central1"
  network    = "projects/my-gcp-project-id/global/networks/my-vpc-network"
  subnet     = "projects/my-gcp-project-id/regions/us-central1/subnetworks/my-proxy-only-subnet"

  // Optional: Provide a certificate for TLS inspection
  // certificate_manager_certificate = "projects/my-gcp-project-id/locations/us-central1/certificates/my-tls-cert"

  labels = {
    environment = "production"
    managed-by  = "terraform"
  }

  policy_rules = [
    {
      name            = "allow-google-apis"
      description     = "Allow access to Google APIs"
      enabled         = true
      priority        = 100
      action          = "ALLOW"
      session_matcher = "host() == 'googleapis.com'"
      tls_inspected   = false // Set to true to inspect this traffic
    },
    {
      name            = "deny-social-media"
      description     = "Deny access to social media sites"
      enabled         = true
      priority        = 200
      action          = "DENY"
      session_matcher = "host() == 'facebook.com' || host() == 'twitter.com'"
      tls_inspected   = false
    },
    {
      name            = "default-allow"
      description     = "Default rule to allow all other traffic"
      enabled         = true
      priority        = 1000
      action          = "ALLOW"
      session_matcher = "true"
      tls_inspected   = false
    }
  ]
}
```

## Requirements

Before this module can be used, you must have the following:

*   **Terraform**: Version `1.3` or later.
*   **Google Cloud Provider**: Version `5.30.0` or later.
*   **APIs**: The following APIs must be enabled in the project:
    *   `networksecurity.googleapis.com`
    *   `compute.googleapis.com`
    *   `certificatemanager.googleapis.com` (if using TLS inspection)
*   **VPC and Subnet**: A VPC network and a dedicated [proxy-only subnet](https://cloud.google.com/vpc/docs/proxy-only-subnets) must exist in the specified location.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `certificate_manager_certificate` | The full self-link of a Certificate Manager certificate to use for TLS inspection. e.g. projects/PROJECT\_ID/locations/REGION/certificates/CERT\_NAME | `string` | `null` | no |
| `ip_address` | The IP address of the gateway. This must be a valid, unused IP address from the proxy-only subnet. If not specified, an IP is automatically allocated. | `string` | `null` | no |
| `labels` | A map of key/value labels to apply to the gateway and policy resources. | `map(string)` | `{}` | no |
| `location` | The Google Cloud region where the Secure Web Proxy will be deployed. | `string` | n/a | yes |
| `name` | The base name for the Secure Web Proxy gateway and its associated policy. | `string` | n/a | yes |
| `network` | The full self-link of the VPC network to which the gateway is attached. e.g. projects/PROJECT\_ID/global/networks/VPC\_NAME | `string` | n/a | yes |
| `policy_description` | An optional description of the gateway policy. | `string` | `"Secure Web Proxy policy managed by Terraform."` | no |
| `policy_rules` | A list of objects defining the rules for the Secure Web Proxy policy. Each object represents a rule. The 'action' can be 'ALLOW' or 'DENY'. The 'session\_matcher' is a CEL expression. | <pre>list(object({<br>    name            = string<br>    description     = optional(string, null)<br>    enabled         = bool<br>    priority        = number<br>    action          = string<br>    session_matcher = string<br>    tls_inspected   = optional(bool, false)<br>  }))</pre> | <pre>[<br>  {<br>    name            = "default-allow-all"<br>    description     = "A default rule to allow all traffic."<br>    enabled         = true<br>    priority        = 1000<br>    action          = "ALLOW"<br>    session_matcher = "true"<br>    tls_inspected   = false<br>  }<br>]</pre> | no |
| `project_id` | The project ID where the Secure Web Proxy and its components will be created. | `string` | n/a | yes |
| `subnet` | The full self-link of the proxy-only subnet to which the gateway is attached. e.g. projects/PROJECT\_ID/regions/REGION/subnetworks/SUBNET\_NAME | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| `gateway_id` | The full ID of the Secure Web Proxy gateway. |
| `gateway_name` | The name of the Secure Web Proxy gateway. |
| `policy_id` | The full ID of the Secure Web Proxy policy. |
| `policy_name` | The name of the Secure Web Proxy policy. |
