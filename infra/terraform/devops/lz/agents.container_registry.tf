// container_registry.tf

module "acr" {
  count = local.enable_agents_resources ? 1 : 0
  # tflint-ignore: terraform_module_pinned_source
  source = "git::https://github.com/shigeyf/terraform-azurerm-reusables.git//infra/terraform/modules/acr?ref=main"

  resource_group_name           = local.agents_resource_group_name
  location                      = var.location
  tags                          = local.agents_tags
  container_registry_name       = local.container_registry_name
  sku                           = local.enable_network_resources ? "Premium" : "Standard"
  enable_user_assigned_identity = false
  enable_public_network_access  = local.enable_network_resources ? false : true
  network_resource_group_name   = local.network_resource_group_name
  private_endpoint_name         = local.enable_network_resources ? local.acr_private_endpoint_name : null
  private_endpoint_subnet_id    = local.enable_network_resources ? local.private_endpoint_subnet_id : null
  private_dns_zone_ids          = var.enable_private_network ? [local.acr_private_dns_zone_id] : []

  override_public_network_access = true # temporary public access enabled with private endpoint for push tasks

  depends_on = [
    azurerm_resource_group.agents,
    module.vnet,
    azurerm_private_dns_zone.this,
  ]
}
