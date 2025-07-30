// main.vnet.tf

locals {
  _subnets = { for index, subnet in var.subnets
    : index => merge(
      merge(
        subnet,
        var.enable_nat_gateway && index != local.gateway_subnet_fixed_name
        ? { nat_gateway = { id = module.natgw[0].resource_id } }
        : {}
      ),
      index == local.gateway_subnet_fixed_name
      ? {}
      : {
        network_security_group = { id = module.nsg[index].resource_id }
      }
    )
  }
}

module "vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.9.3"

  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  address_space = [var.address_prefix]
  subnets       = local._subnets
}
