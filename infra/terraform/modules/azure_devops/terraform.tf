// terraform.tf

terraform {
  required_version = "~> 1.7"
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 1.7"
    }
  }
}

