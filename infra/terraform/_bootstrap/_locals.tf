// _locals.tf

# Local variables for resource names
locals {
  st_short_name        = module.naming.storage_account.short_name
  kv_short_name        = module.naming.key_vault.short_name
  resource_group_name  = "${module.naming.resource_group.name}-${local.rand_id}"
  storage_account_name = "${substr(local.st_short_name, 0, length(local.st_short_name) - 4)}${local.rand_id}"
  keyvault_name        = "${substr(local.kv_short_name, 0, length(local.st_short_name) - 4)}${local.rand_id}"
}
