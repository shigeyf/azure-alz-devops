// _locals.tf

locals {
  create_agents_resource_group_name           = "${module.naming_agents.resource_group.name}-${local.rand_id}"
  create_identity_resource_group_name         = "${module.naming_identity.resource_group.name}-${local.rand_id}"
  create_network_resource_group_name          = "${module.naming_network.resource_group.name}-${local.rand_id}"
  create_agents_aca_infra_resource_group_name = "${module.naming_agents.resource_group.name}-aca-infra-${local.rand_id}"
  create_devbox_resource_group_name           = "${module.naming_devbox.resource_group.name}-${local.rand_id}"
}

locals {
  devbox_suffix_base = concat(var.naming_suffix, ["devbox"], [local.location_short_name])
  devbox_suffix      = lower(join("", local.devbox_suffix_base))
  devbox_suffix_wh   = lower(join("-", local.devbox_suffix_base))
  devbox_suffix_ab   = lower(join("", [for s in local.devbox_suffix_base : substr(s, 0, 1)]))
  devbox_short_name  = "${local.devbox_suffix_ab}${sha256(local.devbox_suffix)}"
}

locals {
  // Identity Resources
  identity_resource_group_name = azurerm_resource_group.identity.name
  identity_tags                = merge(var.tags, { appTag = "identity" })

  // Pipeline Agents Resources
  enable_agents_resources             = var.enable_self_hosted_agents
  enable_agents_on_aca                = true # always true
  enable_agents_on_aci                = true # always true
  agents_resource_group_name          = local.enable_agents_resources ? azurerm_resource_group.agents[0].name : ""
  agents_tags                         = merge(var.tags, { appTag = "agents" })
  container_registry_name             = "${module.naming_agents.container_registry.name}${local.rand_id}"
  uami_container_run_name             = "${module.naming_agents.user_assigned_identity.name}-${local.rand_id}"
  container_app_log_analytics_name    = "${module.naming_agents.log_analytics_workspace.name}-${local.rand_id}"
  container_app_environment_name      = "${module.naming_agents.container_app_environment.name}-${local.rand_id}"
  container_app_workload_profile_name = "Consumption"

  // Network Resources
  enable_network_resources    = var.enable_private_network && var.enable_self_hosted_agents
  network_resource_group_name = local.enable_network_resources ? azurerm_resource_group.network[0].name : ""
  network_tags                = merge(var.tags, { appTag = "network" })
  vnet_name                   = "${module.naming_network.virtual_network.name}-${local.rand_id}"
  nat_gateway_name            = "${module.naming_network.nat_gateway.name}-${local.rand_id}"
  nat_gateway_public_ip_name  = "${module.naming_network.public_ip.name}-${local.rand_id}"
  acr_private_endpoint_name   = "${module.naming_network.private_endpoint.name}-acr-${local.rand_id}"
  blob_private_endpoint_name  = "${module.naming_network.private_endpoint.name}-blob-${local.rand_id}"
  kv_private_endpoint_name    = "${module.naming_network.private_endpoint.name}-kv-${local.rand_id}"

  // DevBox Resources
  enable_devbox              = var.enable_devbox
  devbox_resource_group_name = local.enable_devbox ? azurerm_resource_group.devbox[0].name : ""
  devbox_dev_center_name     = "devct-${substr(local.devbox_short_name, 0, 14)}${local.rand_id}"
  devbox_def_name_prefix     = "devboxdef-${local.devbox_suffix_wh}-${local.rand_id}-"
  devbox_dev_center_con_name = "devctcon-${local.devbox_suffix_wh}-${local.rand_id}"
  devbox_dev_center_net_name = "devctnet-${local.devbox_suffix_wh}-${local.rand_id}"
  devbox_tags                = merge(var.tags, { appTag = "devbox" })
}
