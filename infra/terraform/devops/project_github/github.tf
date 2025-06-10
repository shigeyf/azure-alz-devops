// github.tf

module "github" {
  source = "../../modules/github"

  // Organizations
  organization_name = local.options.github.organization_name

  // Teams
  teams = module.workflow.teams

  // Repository
  main_repository_name       = local.repository_name
  main_repository_files      = module.workflow.workflow_main_files
  use_templates_repository   = var.use_templates_repository
  templates_repository_name  = local.templates_repository_name
  templates_repository_files = module.workflow.workflow_templates_files
  branch_rules               = module.workflow.branch_rules

  // Environments
  default_environments = module.workflow.default_github_environments
  environments         = local.github_environments

  // Variables
  variables = concat(
    local.tfstate_backend_variables,
    local.azure_subscription_variables,
    module.workflow.repo_variables
  )

  // GitHub Runners
  agent_pool_name        = ""
  use_self_hosted_agents = false
}
