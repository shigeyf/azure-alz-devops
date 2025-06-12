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
    replace(
      replace(
        replace(
          replace(
            jsonencode(data.terraform_remote_state.devops.outputs),
            "{project_name}", var.project_name
          ),
          "{random}", local.rand_id
        ),
        "{runner_scope}", local.runner_scope
      ),
      "{runner_group_name}", local.runner_group_name
    )
  )

  options                      = data.terraform_remote_state.devops.outputs.options
  agents_resource_group_name   = local._devops_outputs.devops_agents.resource_group_name
  identity_resource_group_name = local._devops_outputs.devops_identity.resource_group_name
  #network_resource_group_name  = local._devops_outputs.devops_network.resource_group_name
}

// Agent Resources for Self-hosted GitHub Runners
locals {
  acr_login_server                    = local._devops_outputs.devops_agents.acr_login_server
  container_specs                     = local._devops_outputs.container_specs
  container_run_managed_identity_id   = local._devops_outputs.devops_agents.container_run_uami_id
  container_app_environment_id        = local._devops_outputs.devops_agents.container_app_environment_id
  container_app_workload_profile_name = local._devops_outputs.devops_agents.container_app_workload_profile_name
}

// For debug
output "options" {
  value = local.options
}
