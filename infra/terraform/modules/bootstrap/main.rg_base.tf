// rg_base.tf

resource "azurerm_resource_group" "base" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}
