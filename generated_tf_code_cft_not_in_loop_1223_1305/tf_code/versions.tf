# The versions.tf file is used to specify the required Terraform version and provider versions.
terraform {
  # Specifies the required version of Terraform to be used.
  required_version = ">= 1.3"
  required_providers {
    # Specifies the required Google Cloud Platform provider version.
    # The Secure Web Proxy resources are available in the google-beta provider.
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.70.0"
    }
  }
}
