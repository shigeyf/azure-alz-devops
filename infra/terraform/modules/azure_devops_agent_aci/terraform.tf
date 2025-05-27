// terraform.tf

terraform {
  required_version = "~> 1.7"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0, < 4.0.0"
    }
  }
}
