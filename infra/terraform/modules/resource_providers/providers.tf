// provider.tf

provider "azurerm" {
  subscription_id                 = var.subscription_id == "" ? null : var.subscription_id
  resource_provider_registrations = "none"
  features {}
}
