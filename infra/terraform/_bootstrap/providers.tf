// provider.tf

provider "azurerm" {
  storage_use_azuread = true
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
