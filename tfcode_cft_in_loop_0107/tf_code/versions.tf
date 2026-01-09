terraform {
  # Specifies the minimum version of Terraform required to apply this module.
  required_version = ">= 1.5.0"
  required_providers {
    # Specifies the required Google Cloud provider and its version constraints.
    google = {
      source  = "hashicorp/google"
      version = "~> 5.13"
    }
  }
}
