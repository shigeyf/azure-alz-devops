// keyvault.tf

locals {
  additional_ras = var.enable_user_assigned_identity ? {
    customer_managed_key_role_assignment = {
      role_definition_id_or_name = "Key Vault Crypto Officer"
      principal_id               = azurerm_user_assigned_identity.this[0].principal_id
    }
    } : {
    customer_managed_key_role_assignment = {
      role_definition_id_or_name = "Key Vault Crypto Officer"
      principal_id               = module.tfbackend.resource.identity[0].principal_id
    }
  }
}

module "kv" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.10.1"

  name                = var.keyvault_name
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags

  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = "standard"
  public_network_access_enabled   = true
  purge_protection_enabled        = var.purge_protection_enabled
  soft_delete_retention_days      = var.purge_protection_enabled ? var.soft_delete_retention_days : null
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment

  network_acls = {
    default_action = "Allow"
  }

  role_assignments = merge({
    deployment_user_role_assignment = {
      role_definition_id_or_name = "Key Vault Administrator"
      principal_id               = data.azurerm_client_config.current.object_id
    }
  }, local.additional_ras)

  wait_for_rbac_before_secret_operations = {
    create = "60s"
  }

  depends_on = [
    azurerm_resource_group.base,
  ]
}
