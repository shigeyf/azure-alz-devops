// team.tf

locals {
  approvers = [
    for user in data.github_organization.this.users
    : user if contains(var.approvers_group.approvers, user.email)
  ]

  primary_approver_email = length(local.approvers) > 0 ? local.approvers[0].email : ""
  default_commit_email   = coalesce(local.primary_approver_email, data.github_organization.this.login)
}

resource "github_team" "this" {
  name        = var.approvers_group.name
  description = "${var.approvers_group.name}: Approvers for CI/CD Pipeline"
  privacy     = "closed"
}

resource "github_team_repository" "this" {
  team_id    = github_team.this.id
  repository = github_repository.this.name
  permission = "push"

  depends_on = [
    github_team.this,
    github_repository.this,
  ]
}

resource "github_team_membership" "this" {
  for_each = { for approver in local.approvers : approver.id => approver.login }
  team_id  = github_team.this.id
  username = each.value
  role     = "member"
}
