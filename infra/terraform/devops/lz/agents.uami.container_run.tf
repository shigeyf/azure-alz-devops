// uami.container_run.tf

resource "azurerm_user_assigned_identity" "container_run" {
  count               = local.enable_agents_resources ? 1 : 0
  name                = local.uami_container_run_name
  resource_group_name = local.agents_resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_role_assignment" "container_run_ra_acr_pull" {
  count                = local.enable_agents_resources ? 1 : 0
  principal_id         = azurerm_user_assigned_identity.container_run[0].principal_id
  scope                = module.acr[0].output.acr_id
  role_definition_name = "AcrPull"

  depends_on = [
    module.acr,
    azurerm_user_assigned_identity.container_run,
  ]
}

resource "azurerm_role_assignment" "container_run_ra_kv_secrets" {
  count                = local.enable_agents_resources ? 1 : 0
  scope                = local.bootstrap.keyvault_id
  principal_id         = azurerm_user_assigned_identity.container_run[0].principal_id
  role_definition_name = "Key Vault Secrets User"

  depends_on = [
    azurerm_user_assigned_identity.container_run,
  ]
}
