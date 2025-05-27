// github.secret.tf

resource "azurerm_key_vault_secret" "github" {
  for_each     = local.enable_agents_resources && var.enable_github ? { for s in local.github_secrets : s.name => s } : {}
  name         = each.value.name
  value        = each.value.value
  key_vault_id = local.bootstrap.keyvault_id
}
