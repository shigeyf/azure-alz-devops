// environment.tf

resource "github_repository_environment" "this" {
  for_each    = var.environments
  environment = each.value.name
  repository  = github_repository.this.name

  dynamic "reviewers" {
    for_each = each.value.github.enable_reviewers && length(local.approvers) > 0 ? [1] : []
    content {
      teams = [
        github_team.this.id
      ]
    }
  }

  dynamic "deployment_branch_policy" {
    for_each = each.value.github.enable_deployment_branch_policy ? [1] : []
    content {
      protected_branches     = true
      custom_branch_policies = false
    }
  }

  depends_on = [
    github_team_repository.this,
  ]
}
