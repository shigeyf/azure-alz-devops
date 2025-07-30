// local_file.tf

locals {
  _bootstrap_prefix = "bootstrap"
}

resource "local_file" "bootstrap_config" {
  filename = var.bootstrap_config_filename
  content = jsonencode({
    resource_group_name    = local.resource_group_name
    storage_account_name   = local.storage_name
    tfstate_container_name = var.tfstate_container_name
    keyvault_name          = local.keyvault_name
    storage_id             = local.storage_id
    keyvault_id            = local.keyvault_id
  })

  depends_on = [
    azurerm_resource_group.base,
    module.tfbackend,
    module.kv,
  ]
}

resource "local_file" "bootstrap_backend" {
  filename = var.bootstrap_backend_filename
  content = templatefile("${path.module}/backend.tftpl", {
    storage_account_name   = local.storage_name
    tfstate_container_name = var.tfstate_container_name
    bootstrap_prefix       = local._bootstrap_prefix
  })

  depends_on = [
    azurerm_resource_group.base,
    module.tfbackend,
  ]
}

resource "local_file" "tfbackend_config_template" {
  filename = var.tfbackend_config_template_filename
  content = templatefile("${path.module}/azurerm.tfbackend.tpl", {
    storage_account_name   = local.storage_name
    tfstate_container_name = var.tfstate_container_name
  })

  depends_on = [
    azurerm_resource_group.base,
    module.tfbackend,
  ]
}
