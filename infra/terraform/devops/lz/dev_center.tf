// dev_center.tf

resource "azurerm_dev_center" "this" {
  count               = local.enable_devbox ? 1 : 0
  name                = local.devbox_dev_center_name
  location            = var.location
  resource_group_name = local.devbox_resource_group_name
  tags                = local.devbox_tags

  depends_on = [
    azurerm_resource_group.devbox,
  ]
}
