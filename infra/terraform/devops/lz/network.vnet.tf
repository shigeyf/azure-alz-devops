// vnet.tf

module "vnet" {
  count = local.enable_network_resources ? 1 : 0
  # tflint-ignore: terraform_module_pinned_source
  source = "git::https://github.com/shigeyf/terraform-azurerm-reusables.git//infra/terraform/modules/vnet?ref=main"

  resource_group_name = local.network_resource_group_name
  location            = var.location
  tags                = local.network_tags

  vnet_name                  = local.vnet_name
  nat_gateway_name           = local.nat_gateway_name
  nat_gateway_public_ip_name = local.nat_gateway_public_ip_name
  private_dns_zone_names = [
    for zone in azurerm_private_dns_zone.this : {
      name                = zone.name,
      resource_group_name = local.network_resource_group_name,
    }
  ]

  // Options
  address_prefix      = var.vnet_address_prefix
  subnets             = var.vnet_subnets
  enable_nat_gateway  = true
  enable_bastion_host = false
  enable_vpn_gateway  = false

  depends_on = [
    azurerm_resource_group.network,
  ]
}

locals {
  subnet_ids                   = length(module.vnet) > 0 ? module.vnet[0].output.subnet_ids : {}
  private_endpoint_subnet_id   = length(module.vnet) > 0 ? local.subnet_ids[var.vnet_private_endpoint_subnet_name] : null
  container_app_subnet_id      = length(module.vnet) > 0 ? local.subnet_ids[var.vnet_container_app_subnet_name] : null
  container_instance_subnet_id = length(module.vnet) > 0 ? local.subnet_ids[var.vnet_container_instance_subnet_name] : null
}
