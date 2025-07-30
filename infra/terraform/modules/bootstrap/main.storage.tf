// storage.tf

module "tfbackend" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "0.6.3"

  name                = var.storage_account_name
  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags

  account_kind                      = "StorageV2"
  account_replication_type          = "LRS"
  account_tier                      = "Standard"
  min_tls_version                   = "TLS1_2"
  infrastructure_encryption_enabled = true
  public_network_access_enabled     = true

  network_rules = {
    default_action = "Allow"
  }

  containers = {
    tfstate = {
      name = var.tfstate_container_name
    }
  }

  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = var.enable_user_assigned_identity ? [azurerm_user_assigned_identity.this[0].id] : null
  }

  role_assignments = {
    role_assignment_1 = {
      role_definition_id_or_name       = "Storage Blob Data Owner"
      principal_id                     = data.azurerm_client_config.current.object_id
      skip_service_principal_aad_check = false
    }
  }

  customer_managed_key = var.enable_storage_customer_managed_key ? {
    key_vault_resource_id = module.kv.resource_id
    key_name              = azurerm_key_vault_key.tfbackend_cmk[0].name
    user_assigned_identity = var.enable_user_assigned_identity ? {
      resource_id = azurerm_user_assigned_identity.this[0].id
    } : null
  } : null
}
