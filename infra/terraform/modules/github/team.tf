// team.tf

resource "github_team" "this" {
  for_each    = var.teams
  name        = each.key
  description = each.value.description
  privacy     = "closed"
}

resource "github_team_repository" "this" {
  for_each   = var.teams
  team_id    = github_team.this[each.key].id
  repository = github_repository.this.name
  permission = each.value.permission

  depends_on = [
    github_team.this,
    github_repository.this,
  ]
}
