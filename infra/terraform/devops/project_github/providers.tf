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

data "azurerm_key_vault_secret" "github_pat" {
  name         = local.options.github.personal_access_token
  key_vault_id = local.bootstrap.keyvault_id
}

provider "github" {
  token    = data.azurerm_key_vault_secret.github_pat.value
  owner    = local.options.github.organization_name
  base_url = module.github.api_base_url
}
