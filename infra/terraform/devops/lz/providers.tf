// provider.tf

provider "azurerm" {
  subscription_id                 = var.target_subscription_id == "" ? null : var.target_subscription_id
  storage_use_azuread             = true
  resource_provider_registrations = "none"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}
