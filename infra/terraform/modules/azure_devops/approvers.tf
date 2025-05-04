// project_group.tf

locals {
  approvers = [
    for user in data.azuredevops_users.this.users
    : user if contains(var.approvers_group.approvers, user.principal_name)
  ]
}

resource "azuredevops_group" "approver_group" {
  scope        = local.project_id
  display_name = var.approvers_group.name
  description  = "${var.approvers_group.name}: Approvers for CI/CD Pipeline"
}

resource "azuredevops_group_membership" "this" {
  group   = azuredevops_group.approver_group.descriptor
  members = [for user in local.approvers : user.descriptor]
}
