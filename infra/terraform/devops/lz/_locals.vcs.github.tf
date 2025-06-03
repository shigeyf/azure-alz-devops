// _locals.vcs.github.tf

locals {
  vcs_secret_github_personal_access_token       = "github-personal-access-token"
  vcs_secret_github_personal_access_token_agent = "github-personal-access-token-agent"
}

locals {
  github_secrets = [
    {
      name    = local.vcs_secret_github_personal_access_token
      value   = var.github_personal_access_token
      enabled = true
    },
    {
      name    = local.vcs_secret_github_personal_access_token_agent
      value   = var.github_personal_access_token_for_runners
      enabled = local.enable_agents_resources
    },
  ]
}
