// container.tf

module "azuredevops_agent_aca" {
  count  = local.enable_agents_resources && local.enable_agents_on_aca && var.enable_azuredevops ? 1 : 0
  source = "../../modules/azure_devops_agent_aca"

  organization_url_secret_id = azurerm_key_vault_secret.azuredevops[local.vcs_secret_azuredevops_organization_url].versionless_id
  agent_pat_secret_id        = azurerm_key_vault_secret.azuredevops[local.vcs_secret_azuredevops_personal_access_token_agent].versionless_id
  secret_reader_uami_id      = azurerm_user_assigned_identity.container_run[0].id
  acr_login_server           = module.acr[0].output.acr_login_server
}

module "github_runner_aca" {
  count  = local.enable_agents_resources && local.enable_agents_on_aca && var.enable_azuredevops ? 1 : 0
  source = "../../modules/github_runner_aca"

  organization_name     = var.github_organization_name
  enterprise_name       = var.github_enterprise_name
  runner_pat_secret_id  = azurerm_key_vault_secret.github[local.vcs_secret_github_personal_access_token_agent].versionless_id
  secret_reader_uami_id = azurerm_user_assigned_identity.container_run[0].id
  acr_login_server      = module.acr[0].output.acr_login_server
}

module "azuredevops_agent_aci" {
  count  = local.enable_agents_resources && local.enable_agents_on_aci && var.enable_azuredevops ? 1 : 0
  source = "../../modules/azure_devops_agent_aci"

  organization_url_secret_id = azurerm_key_vault_secret.azuredevops[local.vcs_secret_azuredevops_organization_url].versionless_id
  agent_pat_secret_id        = azurerm_key_vault_secret.azuredevops[local.vcs_secret_azuredevops_personal_access_token_agent].versionless_id
}

module "github_runner_aci" {
  count  = local.enable_agents_resources && local.enable_agents_on_aci && var.enable_azuredevops ? 1 : 0
  source = "../../modules/github_runner_aci"

  organization_name    = var.github_organization_name
  runner_pat_secret_id = azurerm_key_vault_secret.github[local.vcs_secret_github_personal_access_token_agent].versionless_id
}

locals {
  container_image_build_tasks = merge(
    length(module.azuredevops_agent_aca) > 0
    ? {
      (module.azuredevops_agent_aca[0].container.registry_task.name) = module.azuredevops_agent_aca[0].container.registry_task
    }
    : {},
    length(module.azuredevops_agent_aci) > 0
    ? {
      (module.azuredevops_agent_aci[0].container.registry_task.name) = module.azuredevops_agent_aci[0].container.registry_task
    }
    : {},
    length(module.github_runner_aca) > 0
    ? {
      (module.github_runner_aca[0].container.registry_task.name) = module.github_runner_aca[0].container.registry_task
    }
    : {},
    length(module.github_runner_aci) > 0
    ? {
      (module.github_runner_aci[0].container.registry_task.name) = module.github_runner_aci[0].container.registry_task
    }
    : {},
  )
}
