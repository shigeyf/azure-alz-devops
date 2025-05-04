// environment.variable.tf

resource "github_actions_environment_variable" "azurerm_client_id" {
  for_each      = var.environments
  repository    = github_repository.this.name
  environment   = github_repository_environment.this[each.key].environment
  variable_name = "AZURE_CLIENT_ID"
  value         = each.value.github.user_assigned_identity_client_id
}
