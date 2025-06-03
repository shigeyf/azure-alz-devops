// container_app_env.tf

module "aca" {
  count                          = local.enable_agents_resources && local.enable_agents_on_aca ? 1 : 0
  source                         = "../../modules/aca_env"
  container_app_environment_name = local.container_app_environment_name
  location                       = var.location
  resource_group_name            = local.agents_resource_group_name
  tags                           = local.agents_tags

  logs_destination                        = "log-analytics"
  log_analytics_workspace_id              = azurerm_log_analytics_workspace.this[0].id
  workload_profile_name                   = local.container_app_workload_profile_name
  container_app_infra_resource_group_name = local.create_agents_aca_infra_resource_group_name
  container_app_subnet_id                 = local.enable_network_resources ? local.container_app_subnet_id : null
  internal_load_balancer_enabled          = local.enable_network_resources ? true : false
  zone_redundancy_enabled                 = local.enable_network_resources ? var.enable_agents_compute_zone_redundancy : false

  depends_on = [
    azurerm_resource_group.agents,
    azurerm_log_analytics_workspace.this,
    module.vnet,
  ]
}
