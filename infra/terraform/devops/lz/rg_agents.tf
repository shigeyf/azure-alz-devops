// rg_pipeline_agents.tf

resource "azurerm_resource_group" "agents" {
  count    = var.enable_self_hosted_agents ? 1 : 0
  name     = local.create_agents_resource_group_name
  location = var.location
  tags     = local.agents_tags
}
