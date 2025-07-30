// uami.tf

resource "azurerm_user_assigned_identity" "this" {
  count               = var.enable_user_assigned_identity ? 1 : 0
  name                = var.storage_uami_name
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = var.tags
}
