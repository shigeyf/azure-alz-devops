// _locals.devops.tf

data "terraform_remote_state" "devops" {
  backend = "azurerm"
  config = {
    use_azuread_auth     = true
    storage_account_name = local.bootstrap.storage_account_name
    container_name       = local.bootstrap.tfstate_container_name
    key                  = var.devops_tfstate_key
  }
}

locals {
  _devops_outputs = jsondecode(
    replace(jsonencode(data.terraform_remote_state.devops.outputs), "{project_name}", var.project_name)
  )
  options = local._devops_outputs.options
  #agents_resource_group_name   = local._devops_outputs.devops_agents.resource_group_name
  identity_resource_group_name = local._devops_outputs.devops_identity.resource_group_name
  #network_resource_group_name  = local._devops_outputs.devops_network.resource_group_name
}

// For debug
output "options" {
  value = local.options
}
