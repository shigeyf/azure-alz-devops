// _outputs.tf

output "output" {
  description = "Output resources of the bootstrap module"
  value = {
    resource_group_name    = local.resource_group_name
    storage_account_name   = local.storage_name
    tfstate_container_name = var.tfstate_container_name
    keyvault_name          = local.keyvault_name
    storage_id             = local.storage_id
    keyvault_id            = local.keyvault_id
  }
}
