// _locals.tf

locals {
  resource_group_name = azurerm_resource_group.base.name
  storage_id          = module.tfbackend.resource_id
  storage_name        = element(reverse(split("/", module.tfbackend.resource_id)), 0)
  keyvault_id         = module.kv.resource_id
  keyvault_name       = element(reverse(split("/", module.kv.resource_id)), 0)
}
