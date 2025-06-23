// dev_center.conn.tf

resource "azurerm_dev_center_network_connection" "this" {
  count               = local.enable_devbox && local.enable_network_resources ? 1 : 0
  name                = local.devbox_dev_center_con_name
  resource_group_name = local.devbox_resource_group_name
  location            = var.location
  tags                = var.tags
  domain_join_type    = "AzureADJoin"
  subnet_id           = local.devbox_subnet_id

  depends_on = [
    azurerm_resource_group.devbox,
    module.vnet,
  ]
}

resource "azurerm_dev_center_attached_network" "this" {
  count                 = local.enable_devbox && local.enable_network_resources ? 1 : 0
  name                  = local.devbox_dev_center_net_name
  dev_center_id         = azurerm_dev_center.this[0].id
  network_connection_id = azurerm_dev_center_network_connection.this[0].id

  depends_on = [
    azurerm_dev_center.this,
    azurerm_dev_center_network_connection.this,
  ]
}
