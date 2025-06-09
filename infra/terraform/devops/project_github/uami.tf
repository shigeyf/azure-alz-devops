// uami.tf

resource "azurerm_user_assigned_identity" "this" {
  for_each            = { for key, env in module.workflow.github_environments : key => env }
  name                = "${local.uami_name_prefix}${each.key}"
  resource_group_name = local.identity_resource_group_name
  location            = var.location
  tags                = var.tags
}
