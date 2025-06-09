// role.subscription.tf

locals {
  _subscription_role_assignments = { for key, env in module.workflow.github_environments :
    key => {
      job             = env.job
      environment     = env.environment
      subscription_id = var.subscriptions[env.environment].id
      principal_id    = azurerm_user_assigned_identity.this[key].principal_id
    } if lookup(var.subscriptions, env.environment, { id = "" }) != { id = "" }
  }
}

resource "azurerm_role_assignment" "sub_reader" {
  for_each = {
    for key, ra in local._subscription_role_assignments
    : key => ra if ra.job == module.workflow.job_reader
  }
  role_definition_name = "Reader"
  scope                = "/subscriptions/${each.value.subscription_id}"
  principal_id         = each.value.principal_id

  depends_on = [
    azurerm_user_assigned_identity.this,
  ]
}

resource "azurerm_role_assignment" "sub_contributor" {
  for_each = {
    for key, ra in local._subscription_role_assignments
    : key => ra if ra.job == module.workflow.job_contributor
  }
  role_definition_name = "Contributor"
  scope                = "/subscriptions/${each.value.subscription_id}"
  principal_id         = each.value.principal_id

  depends_on = [
    azurerm_user_assigned_identity.this,
  ]
}
