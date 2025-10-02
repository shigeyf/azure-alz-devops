// container_registry.tf

locals {
  _identity_type = var.enable_user_assigned_identity ? "SystemAssigned, UserAssigned" : "SystemAssigned"
  _identity_ids  = var.enable_user_assigned_identity ? [azurerm_user_assigned_identity.this[0].id] : null
}

resource "azurerm_container_registry" "this" {
  name                = var.container_registry_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  sku                           = var.sku
  admin_enabled                 = var.admin_enabled
  public_network_access_enabled = var.override_public_network_access ? true : (var.enable_public_network_access ? true : false)
  network_rule_bypass_option    = var.network_rule_bypass_option
  export_policy_enabled         = var.export_policy_enabled

  identity {
    type         = local._identity_type
    identity_ids = local._identity_ids
  }

  dynamic "encryption" {
    for_each = var.enable_customer_managed_key && var.enable_user_assigned_identity ? [1] : []
    content {
      key_vault_key_id   = var.key_vault_key_id
      identity_client_id = azurerm_user_assigned_identity.this[0].client_id
    }
  }

  depends_on = [
    azurerm_user_assigned_identity.this,
    time_sleep.wait_for_acr_ra_kv_propagation,
  ]
}
