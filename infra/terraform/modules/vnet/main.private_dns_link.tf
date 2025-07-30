// main.private_dns_link.tf

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each              = { for index, zone in var.private_dns_zone_names : index => zone }
  name                  = "link-${module.vnet.name}_${var.resource_group_name}"
  resource_group_name   = each.value.resource_group_name
  tags                  = var.tags
  private_dns_zone_name = each.value.name
  virtual_network_id    = module.vnet.resource_id
  registration_enabled  = false
}
