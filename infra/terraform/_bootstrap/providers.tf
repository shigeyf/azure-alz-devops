// provider.tf

provider "azurerm" {
  storage_use_azuread = true
  subscription_id     = var.target_subscription_id == "" ? null : var.target_subscription_id
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
