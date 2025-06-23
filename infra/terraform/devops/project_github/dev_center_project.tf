// dev_center_project.tf

resource "azurerm_dev_center_project" "this" {
  count                      = var.use_devbox && local.options.devbox_enabled ? 1 : 0
  name                       = local.devbox_project_name
  location                   = var.location
  resource_group_name        = local.devbox_resource_group_name
  tags                       = var.tags
  description                = "Dev Center Project for ${var.project_name}"
  dev_center_id              = local.devbox_dev_center_id
  maximum_dev_boxes_per_user = var.devbox_maximum_dev_boxes_per_user
}
