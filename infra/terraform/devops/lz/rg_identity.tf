// rg_identity.tf

resource "azurerm_resource_group" "identity" {
  name     = local.create_identity_resource_group_name
  location = var.location
  tags     = var.tags
}
