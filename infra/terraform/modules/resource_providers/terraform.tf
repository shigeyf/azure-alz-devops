// terraform.tf

terraform {
  required_version = "~> 1.7"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    #null = {
    #  source  = "hashicorp/null"
    #  version = "~> 3.2"
    #}
  }
}
