// role_assignment_kv.tf

resource "azurerm_role_assignment" "acr_ra_kv" {
  count                = var.enable_customer_managed_key && var.enable_user_assigned_identity ? 1 : 0
  scope                = var.keyvault_id
  principal_id         = azurerm_user_assigned_identity.this[0].principal_id
  role_definition_name = "Key Vault Crypto Officer"

  depends_on = [
    azurerm_user_assigned_identity.this,
  ]
}

resource "time_sleep" "wait_for_acr_ra_kv_propagation" {
  count           = var.enable_customer_managed_key && var.enable_user_assigned_identity ? 1 : 0
  create_duration = var.ra_propagation_time
  depends_on = [
    azurerm_role_assignment.acr_ra_kv,
  ]
}
