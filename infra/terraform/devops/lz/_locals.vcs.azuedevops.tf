// _locals.vcs.azuredevops.tf

locals {
  vcs_secret_azuredevops_organization_url            = "azuredevops-organization-url"
  vcs_secret_azuredevops_personal_access_token_agent = "azuredevops-personal-access-token-agent"
}

locals {
  azuredevops_secrets = [
    {
      name  = local.vcs_secret_azuredevops_organization_url
      value = "https://dev.azure.com/${var.azuredevops_organization_name}"
    },
    {
      name  = local.vcs_secret_azuredevops_personal_access_token_agent
      value = "${var.azuredevops_personal_access_token_for_agents}"
    }
  ]
}
