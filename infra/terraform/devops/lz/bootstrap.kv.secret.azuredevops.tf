// azuredevops.secret.tf

resource "azurerm_key_vault_secret" "azuredevops" {
  for_each     = local.enable_agents_resources && var.enable_azuredevops ? { for s in local.azuredevops_secrets : s.name => s } : {}
  name         = each.value.name
  value        = each.value.value
  key_vault_id = local.bootstrap.keyvault_id
}
