// environment.tf

resource "azuredevops_environment" "this" {
  for_each    = var.environments
  name        = each.value.name
  project_id  = local.project_id
  description = each.value.description
}
