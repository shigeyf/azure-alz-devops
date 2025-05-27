// private_endpoint.tf

locals {
  private_endpoints = [
    {
      name                 = local.bootstrap.storage_account_name
      pe_name              = local.blob_private_endpoint_name
      resource_id          = local.bootstrap.storage_id
      private_dns_zone_ids = [local.blob_private_dns_zone_id]
      subresource_name     = "Blob"
    },
    {
      name                 = local.bootstrap.keyvault_name
      pe_name              = local.kv_private_endpoint_name
      resource_id          = local.bootstrap.keyvault_id
      private_dns_zone_ids = [local.kv_private_dns_zone_id]
      subresource_name     = "vault"
    },
  ]
}

resource "azurerm_private_endpoint" "bootstrap" {
  for_each            = local.enable_network_resources ? { for pe in local.private_endpoints : pe.name => pe } : {}
  name                = each.value.pe_name
  location            = var.location
  resource_group_name = local.network_resource_group_name
  tags                = var.tags
  subnet_id           = local.private_endpoint_subnet_id

  private_service_connection {
    name                           = "connection-${each.value.name}"
    private_connection_resource_id = each.value.resource_id
    is_manual_connection           = false
    subresource_names              = [each.value.subresource_name]
  }

  private_dns_zone_group {
    name                 = "dns-zone-group"
    private_dns_zone_ids = each.value.private_dns_zone_ids
  }

  depends_on = [
    azurerm_resource_group.network,
    module.vnet,
    azurerm_private_dns_zone.this,
  ]
}
