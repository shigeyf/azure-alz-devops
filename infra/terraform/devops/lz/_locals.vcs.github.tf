// _locals.vcs.github.tf

locals {
  vcs_secret_github_personal_access_token_agent = "github-personal-access-token-agent"
}

locals {
  github_secrets = [
    {
      name  = local.vcs_secret_github_personal_access_token_agent
      value = "${var.github_personal_access_token_for_runners}"
    }
  ]
}
