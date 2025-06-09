// environment.tf

locals {
  _environments_branch_deployment_policies = flatten(
    [for env_key, env in var.environments : [
      for branch_pattern in env.branch_policy_branch_patterns : {
        environment    = env.name
        branch_pattern = branch_pattern
      }
    ]]
  )
}

resource "github_repository_environment" "default" {
  for_each    = var.default_environments
  environment = each.value
  repository  = github_repository.this.name

  depends_on = [
    github_team_repository.this,
  ]
}

resource "github_repository_environment" "this" {
  for_each            = { for env in var.environments : env.name => env }
  environment         = each.value.name
  repository          = github_repository.this.name
  can_admins_bypass   = each.value.can_admins_bypass
  prevent_self_review = each.value.prevent_self_review
  wait_timer          = each.value.wait_timer

  reviewers {
    teams = [for reviewer in each.value.reviewers : github_team.this[reviewer].id]
  }

  deployment_branch_policy {
    protected_branches     = each.value.protected_branches
    custom_branch_policies = each.value.custom_branch_policies
  }

  depends_on = [
    github_team.this,
    github_team_repository.this,
  ]
}

resource "github_repository_environment_deployment_policy" "this" {
  for_each = { for policy in local._environments_branch_deployment_policies :
    "${policy.environment}_${policy.branch_pattern}" => policy
  }
  environment    = github_repository_environment.this[each.value.environment].environment
  repository     = github_repository.this.name
  branch_pattern = each.value.branch_pattern

  depends_on = [
    github_repository.this,
    github_repository_environment.this,
  ]
}
