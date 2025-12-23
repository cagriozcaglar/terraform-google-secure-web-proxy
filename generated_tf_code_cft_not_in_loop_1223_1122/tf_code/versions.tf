# Specifies Terraform settings, including the required providers.
terraform {
  # The minimum version of Terraform to use.
  required_version = ">= 1.3"
  # The providers required by this module.
  required_providers {
    # The Google Cloud provider.
    google = {
      # The source of the provider.
      source  = "hashicorp/google"
      # The minimum version of the provider to use.
      version = ">= 5.30.0"
    }
  }
}
