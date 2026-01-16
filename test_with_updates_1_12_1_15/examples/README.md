# Basic Secure Web Proxy Example

This example demonstrates how to use the Secure Web Proxy module to create a gateway and an associated security policy within a new VPC network.

The example will:
- Enable the required Google Cloud APIs.
- Create a new VPC network.
- Deploy a Secure Web Proxy gateway into the specified region and attach it to the new VPC.
- Create a security policy with two rules:
    1. An `ALLOW` rule with priority 100 for traffic to `*.google.com`.
    2. A `DENY` rule with priority 1000 for all other traffic.

## How to use this example

To run this example, you need to:

1.  **Authenticate with Google Cloud:**
