// rg_pipeline_agents.tf

resource "azurerm_resource_group" "network" {
  count    = local.enable_network_resources ? 1 : 0
  name     = local.create_network_resource_group_name
  location = var.location
  tags     = local.network_tags
}
