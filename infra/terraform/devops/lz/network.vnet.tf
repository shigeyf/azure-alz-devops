// vnet.tf

locals {
  _vnet_subnets = merge({
    (var.vnet_private_endpoint_subnet_name) = {
      name                  = var.vnet_private_endpoint_subnet_name
      address_prefix        = var.vnet_private_endpoint_subnet_address_prefix
      naming_prefix_enabled = true
    },
    "GatewaySubnet" = {
      "name"                  = "GatewaySubnet"
      "address_prefix"        = var.vnet_gateway_subnet_address_prefix
      "naming_prefix_enabled" = false
    },
    (var.vnet_container_instance_subnet_name) = {
      name                  = var.vnet_container_instance_subnet_name
      address_prefix        = var.vnet_container_instance_subnet_address_prefix
      naming_prefix_enabled = true
      delegation = [
        {
          name = "Microsoft.ContainerInstance/containerGroups"
          service_delegation = {
            name    = "Microsoft.ContainerInstance/containerGroups"
            actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
          }
        }
      ]
    }
    (var.vnet_container_app_subnet_name) = {
      name                  = var.vnet_container_app_subnet_name
      address_prefix        = var.vnet_container_app_subnet_address_prefix
      naming_prefix_enabled = true
      delegation = [
        {
          name = "Microsoft.App/environments"
          service_delegation = {
            name    = "Microsoft.App/environments"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
          }
        }
      ]
    }
    },
    local.enable_devbox
    ? {
      (var.vnet_devbox_subnet_name) = {
        name                  = var.vnet_devbox_subnet_name
        address_prefix        = var.vnet_devbox_subnet_address_prefix
        naming_prefix_enabled = true
      },
    }
    : {}
  )
}

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
  subnets             = local._vnet_subnets
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
  devbox_subnet_id             = length(module.vnet) > 0 && local.enable_devbox ? local.subnet_ids[var.vnet_devbox_subnet_name] : null
}
