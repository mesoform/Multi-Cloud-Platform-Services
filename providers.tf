terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.14.0"
    }
    google = {
      source = "hashicorp/google"
      version = ">=3.55.0, <4.0.0"
    }
    google-beta = {
      source = "hashicorp/google-beta"
      version = ">=3.55.0, <4.0.0"
    }
  }
}