// storage.cmk.tf

locals {
  _storage_cmk_name = "cmk-${var.storage_account_name}"
}

# module "tfbackend_cmk" {
#   count = var.enable_storage_customer_managed_key ? 1 : 0

#   # tflint-ignore: terraform_module_pinned_source
#   source = "git::https://github.com/shigeyf/terraform-azurerm-reusables.git//infra/terraform/modules/keyvault_key?ref=main"

#   key_name    = local._storage_cmk_name
#   keyvault_id = module.kv.output.keyvault_id
#   key_policy  = var.storage_customer_managed_key_policy

#   depends_on = [
#     null_resource.wait_for_propagation,
#   ]
# }

resource "azurerm_key_vault_key" "tfbackend_cmk" {
  count = var.enable_storage_customer_managed_key ? 1 : 0

  name         = local._storage_cmk_name
  key_vault_id = module.kv.resource_id
  key_type     = var.storage_customer_managed_key_policy.key_type
  key_size     = var.storage_customer_managed_key_policy.key_size
  curve        = var.storage_customer_managed_key_policy.curve_type

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  expiration_date = var.storage_customer_managed_key_policy.expiration_date != null ? var.storage_customer_managed_key_policy.expiration_date : null

  dynamic "rotation_policy" {
    for_each = var.storage_customer_managed_key_policy.rotation_policy != null ? [1] : []
    content {
      dynamic "automatic" {
        for_each = var.storage_customer_managed_key_policy.rotation_policy.automatic != null ? [1] : []
        content {
          time_after_creation = var.storage_customer_managed_key_policy.rotation_policy.automatic.time_after_creation
          time_before_expiry  = var.storage_customer_managed_key_policy.rotation_policy.automatic.time_before_expiry
        }
      }
      expire_after         = var.storage_customer_managed_key_policy.rotation_policy.expire_after
      notify_before_expiry = var.storage_customer_managed_key_policy.rotation_policy.notify_before_expiry
    }
  }

  depends_on = [
    module.kv,
  ]

  lifecycle {
    # ignore_changes = [
    #   id,
    #   resource_id,
    #   version,
    #   expiration_date,
    #   n,
    #   e,
    #   x,
    #   y,
    #   public_key_openssh,
    #   public_key_pem,
    # ]
  }
}
