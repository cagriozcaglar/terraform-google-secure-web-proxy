# This file declares the variables used in the example's main.tf.

variable "project_id" {
  description = "The GCP project ID to deploy the resources in."
  type        = string
}

variable "region" {
  description = "The GCP region to deploy the Secure Web Proxy gateway in."
  type        = string
  default     = "us-central1"
}
