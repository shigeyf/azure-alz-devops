// repo.oidc_template.tf

# resource "github_actions_repository_oidc_subject_claim_customization_template" "this" {
#   repository  = github_repository.this.name
#   use_default = false
#   include_claim_keys = [
#     "repository",
#     "environment",
#     #"job_workflow_ref"
#   ]

#   depends_on = [
#     github_repository.this,
#   ]
# }

locals {
  oidc_fedarations = {
    for env_key, env in var.environments : env_key => {
      org     = var.organization_name
      repo    = var.main_repository_name
      issuer  = "https://token.actions.githubusercontent.com"
      prefix  = "sc-github-${var.organization_name}-${var.main_repository_name}",
      subject = "repo:${var.organization_name}/${var.main_repository_name}:environment:${env.name}"
    }
  }
}
