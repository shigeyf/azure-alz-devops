// _outputs.tf

output "output" {
  value = {
    resource_group_name    = module.bootstrap.output.resource_group_name
    storage_account_name   = module.bootstrap.output.storage_account_name
    tfstate_container_name = module.bootstrap.output.tfstate_container_name
    keyvault_name          = module.bootstrap.output.keyvault_name
    storage_id             = module.bootstrap.output.storage_id
    keyvault_id            = module.bootstrap.output.keyvault_id
  }
  description = "Ouputput from the bootstrap module"
}
