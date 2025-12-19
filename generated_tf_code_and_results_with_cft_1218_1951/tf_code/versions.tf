# The versions.tf file is used to specify the required Terraform version and provider versions.
terraform {
  # Specifies the required version of Terraform.
  required_version = ">= 1.3.0"
  # Specifies the required versions for providers used in the module.
  required_providers {
    # The Google Cloud provider is required for managing GCP resources.
    google = {
      source  = "hashicorp/google"
      version = "~> 5.14"
    }
  }
}
