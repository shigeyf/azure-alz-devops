// dev_center_project.pool.tf

resource "azurerm_dev_center_project_pool" "this" {
  for_each                = var.use_devbox && local.options.devbox_enabled ? local.devbox_definitions : {}
  name                    = "${local.devbox_project_pool_prefix}${each.key}"
  location                = var.location
  tags                    = var.tags
  dev_center_project_id   = azurerm_dev_center_project.this[0].id
  dev_box_definition_name = each.value.name

  dev_center_attached_network_name = local.options.private_network_enabled ? local.devbox_dev_center_network_name : null

  local_administrator_enabled             = var.devbox_local_administrator_enabled
  stop_on_disconnect_grace_period_minutes = var.devbox_stop_on_disconnect_grace_period_minutes
}

# resource "azapi_resource" "dev_center_project_pool" {
#   for_each  = false && var.use_devbox && local.options.devbox_enabled ? local.devbox_definitions : {}
#   type      = "Microsoft.DevCenter/projects/pools@2025-04-01-preview"
#   name      = "${local.devbox_project_pool_prefix}${each.key}"
#   parent_id = azurerm_dev_center_project.this[0].id
#   location  = var.location
#   tags      = var.tags

#   body = {
#     properties = {
#       devBoxDefinitionName  = each.value.name
#       devBoxDefinitionType  = "Reference"
#       displayName           = "${local.devbox_project_pool_prefix}${each.key}"
#       licenseType           = "Windows_Client"
#       localAdministrator    = var.devbox_local_administrator_enabled ? "Enabled" : "Disabled"
#       networkConnectionName = local.options.private_network_enabled ? local.devbox_dev_center_network_name : null
#       singleSignOnStatus    = "Enabled"
#       stopOnDisconnect = {
#         gracePeriodMinutes = var.devops_stop_on_disconnect_grace_period_minutes
#         status             = "Enabled"
#       }
#       stopOnNoConnect = {
#         gracePeriodMinutes = var.devops_stop_on_no_connect_grace_period_minutes
#         status             = "Enabled"
#       }
#       virtualNetworkType = local.options.private_network_enabled ? "Unmanaged" : "Managed"
#     }
#   }
# }
