# This file provisions the necessary infrastructure and instantiates the Secure Web Proxy module.

# Configure the Google Cloud provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# Enable the necessary APIs for the project
resource "google_project_service" "apis" {
  for_each = toset([
    "networkservices.googleapis.com",
    "networksecurity.googleapis.com",
    "compute.googleapis.com"
  ])
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

# Create a VPC network to attach the Secure Web Proxy gateway to.
resource "google_compute_network" "main" {
  project                 = var.project_id
  name                    = "swp-example-network"
  auto_create_subnetworks = true
  depends_on = [
    google_project_service.apis
  ]
}

# Instantiate the Secure Web Proxy module
module "secure_web_proxy" {
  source = "../../"

  # Required variables
  name    = "swp-example-instance"
  network = google_compute_network.main.self_link

  # Optional variables
  project_id = var.project_id
  region     = var.region
  labels = {
    "environment" = "example"
  }
  gateway_description = "An example Secure Web Proxy gateway."
  policy_description  = "An example security policy for the SWP gateway."

  # Define a set of rules for the security policy.
  # This example allows traffic to google.com and denies all other traffic.
  rules = [
    {
      name            = "allow-google"
      priority        = 100
      session_matcher = "host().endsWith('.google.com')"
      basic_profile   = "ALLOW"
    },
    {
      name            = "deny-all"
      priority        = 1000 # Lowest priority rule
      session_matcher = "true" # Matches all sessions
      basic_profile   = "DENY"
    }
  ]

  # To enable TLS Inspection, uncomment the following line and provide a valid
  # Certificate Manager certificate self-link.
  # tls_inspection_policy_certificate_id = "projects/your-project-id/locations/global/certificates/your-certificate"
}
