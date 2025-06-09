// environment.variable.tf

locals {
  _environment_variables = flatten(
    [for env in var.environments : [
      for variable in env.variables : {
        env   = env.name
        name  = variable.name
        value = variable.value
      }
    ]]
  )
}

resource "github_actions_environment_variable" "this" {
  for_each      = { for e in local._environment_variables : "${e.env}_${e.name}" => e }
  repository    = github_repository.this.name
  environment   = github_repository_environment.this[each.value.env].environment
  variable_name = each.value.name
  value         = each.value.value
}
