// private_dns_zone.tf

locals {
  private_dns_zones = [
    "privatelink.azurecr.io",
    "privatelink.blob.core.windows.net",
    "privatelink.vaultcore.azure.net",
  ]
}

resource "azurerm_private_dns_zone" "this" {
  for_each            = local.enable_network_resources ? toset(local.private_dns_zones) : []
  name                = each.value
  resource_group_name = local.network_resource_group_name
  tags                = local.network_tags

  depends_on = [
    azurerm_resource_group.network,
  ]
}

locals {
  acr_private_dns_zone_id  = local.enable_network_resources ? azurerm_private_dns_zone.this["privatelink.azurecr.io"].id : null
  blob_private_dns_zone_id = local.enable_network_resources ? azurerm_private_dns_zone.this["privatelink.blob.core.windows.net"].id : null
  kv_private_dns_zone_id   = local.enable_network_resources ? azurerm_private_dns_zone.this["privatelink.vaultcore.azure.net"].id : null
}
