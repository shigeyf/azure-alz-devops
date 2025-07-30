// main.avm_nsg.tf

locals {
  _vnet_name_array = split("-", var.vnet_name)
  _nsg_basename    = join("-", [var.nsg_name_prefix], slice(local._vnet_name_array, 1, length(local._vnet_name_array)))
}

module "nsg" {
  for_each = { for index, subnet in var.subnets : index => subnet if subnet.name != local.gateway_subnet_fixed_name }
  source   = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version  = "0.5.0"

  name                = "${local._nsg_basename}-${each.value.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}
