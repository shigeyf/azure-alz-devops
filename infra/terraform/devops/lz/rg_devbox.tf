// rg_devbox.tf

resource "azurerm_resource_group" "devbox" {
  count    = var.enable_devbox ? 1 : 0
  name     = local.create_devbox_resource_group_name
  location = var.location
  tags     = local.devbox_tags
}
