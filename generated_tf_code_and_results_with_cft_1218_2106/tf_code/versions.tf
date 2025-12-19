# This file contains the provider requirements for the module.
terraform {
  # This module is compatible with Terraform 1.3 and higher.
  required_version = ">= 1.3"

  # This module requires the google-beta provider to manage Secure Web Proxy resources.
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.10.0"
    }
  }
}
