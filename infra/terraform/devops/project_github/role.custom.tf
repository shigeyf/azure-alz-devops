// role.custom.tf

resource "azurerm_role_definition" "custom_ra_writer" {
  for_each          = var.subscriptions
  name              = "[Custom] Role Assignments Writer ${each.key} for ${var.project_name}"
  description       = "Manage RoleAssignments read/write under this subscription"
  scope             = "/subscriptions/${each.value.id}"
  assignable_scopes = ["/subscriptions/${each.value.id}"]
  permissions {
    actions = [
      "Microsoft.Authorization/roleAssignments/write"
    ]
    not_actions = []
  }
}

resource "time_sleep" "wait_for_role_propagation" {
  create_duration = var.role_propagation_time
  depends_on = [
    azurerm_role_definition.custom_ra_writer,
  ]
}

resource "azurerm_role_assignment" "custom_ra_writer" {
  for_each = {
    for key, ra in local._subscription_role_assignments
    : key => ra if ra.job == module.workflow.job_contributor
  }
  role_definition_name = azurerm_role_definition.custom_ra_writer[each.value.environment].name
  scope                = "/subscriptions/${each.value.subscription_id}"
  principal_id         = each.value.principal_id

  depends_on = [
    time_sleep.wait_for_role_propagation,
    azurerm_user_assigned_identity.this,
  ]
}
