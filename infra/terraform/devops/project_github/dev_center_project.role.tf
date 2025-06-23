// dev_center_project.role.tf

resource "azurerm_role_assignment" "dev_center_project_admin" {
  count                = var.use_devbox && local.options.devbox_enabled ? 1 : 0
  principal_id         = data.azurerm_client_config.current.object_id
  scope                = azurerm_dev_center_project.this[0].id
  role_definition_name = "DevCenter Project Admin"

  depends_on = [
    azurerm_dev_center_project.this,
  ]
}

resource "azurerm_role_assignment" "dev_center_project_user" {
  count                = var.use_devbox && local.options.devbox_enabled ? 1 : 0
  principal_id         = data.azurerm_client_config.current.object_id
  scope                = azurerm_dev_center_project.this[0].id
  role_definition_name = "DevCenter Dev Box User"

  depends_on = [
    azurerm_dev_center_project.this,
  ]
}
