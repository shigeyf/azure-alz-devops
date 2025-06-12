// _outputs.tf

output "devops_agents" {
  value = {
    resource_group_name                 = length(azurerm_resource_group.agents) > 0 ? azurerm_resource_group.agents[0].name : null
    container_run_uami_id               = length(azurerm_user_assigned_identity.container_run) > 0 ? azurerm_user_assigned_identity.container_run[0].id : null
    container_run_uami_principal_id     = length(azurerm_user_assigned_identity.container_run) > 0 ? azurerm_user_assigned_identity.container_run[0].principal_id : null
    acr_id                              = length(module.acr) > 0 ? module.acr[0].output.acr_id : null
    acr_login_server                    = length(module.acr) > 0 ? module.acr[0].output.acr_login_server : null
    log_analytics_id                    = length(azurerm_log_analytics_workspace.this) > 0 ? azurerm_log_analytics_workspace.this[0].id : null
    container_app_environment_id        = length(module.aca) > 0 ? module.aca[0].output.container_app_environment_id : null
    container_app_workload_profile_name = length(module.aca) > 0 ? local.container_app_workload_profile_name : null
  }
  description = "Agents resources"
}

output "devops_identity" {
  value = {
    resource_group_name = local.identity_resource_group_name
  }
  description = "Identity resources"
}

output "devops_network" {
  value = {
    resource_group_name = length(azurerm_resource_group.network) > 0 ? azurerm_resource_group.network[0].name : null
    vnet                = length(module.vnet) > 0 ? module.vnet[0].output : null
    private_dns_zones   = { for index, z in azurerm_private_dns_zone.this : index => z.id }
    private_endpoints   = { for index, pe in azurerm_private_endpoint.bootstrap : index => pe.id }
    aca_subnet_id       = local.container_app_subnet_id
    aci_subnet_id       = local.container_instance_subnet_id
  }
  description = "Network resources"
}

output "container_specs" {
  value = {
    azuredevops_agent_aca = length(module.azuredevops_agent_aca) > 0 ? module.azuredevops_agent_aca[0] : null
    azuredevops_agent_aci = length(module.azuredevops_agent_aci) > 0 ? module.azuredevops_agent_aci[0] : null
    github_runner_aca     = length(module.github_runner_aca) > 0 ? module.github_runner_aca[0] : null
    github_runner_aci     = length(module.github_runner_aci) > 0 ? module.github_runner_aci[0] : null
  }
  description = "Container parameters for Azure DevOps agents and/or GitHub runners"
}

output "options" {
  value = {
    enable_azuredevops      = var.enable_azuredevops
    enable_github           = var.enable_github
    self_hosted_enabled     = var.enable_self_hosted_agents
    private_network_enabled = var.enable_private_network

    azuredevops = {
      organization_name     = var.azuredevops_organization_name
      personal_access_token = local.vcs_secret_azuredevops_personal_access_token
    }
    github = {
      organization_name     = var.github_organization_name
      enterprise_name       = var.github_enterprise_name
      personal_access_token = local.vcs_secret_github_personal_access_token
    }
  }
}
