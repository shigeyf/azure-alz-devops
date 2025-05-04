// repo.main.variable.tf

resource "github_actions_variable" "this" {
  for_each      = { for v in var.variables : v.name => v }
  repository    = github_repository.this.name
  variable_name = each.value.name
  value         = each.value.value
}
