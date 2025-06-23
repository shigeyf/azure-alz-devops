// dev_center.conn.tf

resource "azurerm_dev_center_network_connection" "this" {
  count               = local.enable_devbox && local.enable_network_resources ? 1 : 0
  name                = local.devbox_network_conn_name
  resource_group_name = local.devbox_resource_group_name
  location            = var.location
  tags                = var.tags
  domain_join_type    = "AzureADJoin"
  subnet_id           = local.container_app_subnet_id

  depends_on = [
    azurerm_resource_group.devbox,
    module.vnet,
  ]
}
