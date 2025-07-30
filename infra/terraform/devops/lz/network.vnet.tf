// vnet.tf

locals {
  _vnet_subnets = merge({
    (var.vnet_private_endpoint_subnet_name) = {
      name                              = "snet-${var.vnet_private_endpoint_subnet_name}"
      address_prefix                    = var.vnet_private_endpoint_subnet_address_prefix
      default_outbound_access_enabled   = false
      private_endpoint_network_policies = "Disabled"
    },
    "GatewaySubnet" = {
      name                              = "GatewaySubnet"
      address_prefix                    = var.vnet_gateway_subnet_address_prefix
      private_endpoint_network_policies = "Disabled"
    },
    (var.vnet_container_instance_subnet_name) = {
      name                              = "snet-${var.vnet_container_instance_subnet_name}"
      address_prefix                    = var.vnet_container_instance_subnet_address_prefix
      default_outbound_access_enabled   = false
      private_endpoint_network_policies = "Disabled"
      delegations = [
        {
          name = "Microsoft.ContainerInstance/containerGroups"
          service_delegation = {
            name = "Microsoft.ContainerInstance/containerGroups"
          }
        }
      ]
    }
    (var.vnet_container_app_subnet_name) = {
      name                              = "snet-${var.vnet_container_app_subnet_name}"
      address_prefix                    = var.vnet_container_app_subnet_address_prefix
      default_outbound_access_enabled   = false
      private_endpoint_network_policies = "Disabled"
      delegations = [
        {
          name = "Microsoft.App/environments"
          service_delegation = {
            name = "Microsoft.App/environments"
          }
        }
      ]
    }
    },
    local.enable_devbox
    ? {
      (var.vnet_devbox_subnet_name) = {
        name                              = "snet-${var.vnet_devbox_subnet_name}"
        address_prefix                    = var.vnet_devbox_subnet_address_prefix
        default_outbound_access_enabled   = false
        private_endpoint_network_policies = "Disabled"
      },
    }
    : {}
  )
}

module "vnet" {
  count  = local.enable_network_resources ? 1 : 0
  source = "../../modules/vnet"

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

  address_prefix     = var.vnet_address_prefix
  subnets            = local._vnet_subnets
  enable_nat_gateway = true

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
