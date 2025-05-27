// log_analytics.tf

resource "azurerm_log_analytics_workspace" "this" {
  count               = var.enable_self_hosted_agents ? 1 : 0
  name                = local.container_app_log_analytics_name
  location            = var.location
  resource_group_name = local.agents_resource_group_name
  tags                = var.tags

  sku               = "PerGB2018"
  retention_in_days = 30
}
