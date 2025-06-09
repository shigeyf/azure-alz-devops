// workflow.tf

module "workflow" {
  source = "../../modules/github_workflows"

  organization_name         = local.options.github.organization_name
  project_name              = var.project_name
  repository_name           = local.repository_name
  templates_repository_name = local.templates_repository_name
  use_templates_repository  = var.use_templates_repository
}

locals {
  github_environments = { for key, env in module.workflow.github_environments : key => merge(env, {
    variables = [
      {
        name  = "AZURE_SUBSCRIPTION_ID"
        value = var.subscriptions[env.environment].id
      },
      {
        name  = "AZURE_CLIENT_ID"
        value = azurerm_user_assigned_identity.this[key].client_id
      },
    ]
  }) }
}

output "github_environments" {
  value = module.workflow.github_environments
}
