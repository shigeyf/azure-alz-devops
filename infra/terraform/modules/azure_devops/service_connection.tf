// service_connection.tf

resource "azuredevops_serviceendpoint_azurerm" "this" {
  for_each                               = var.environments
  project_id                             = local.project_id
  service_endpoint_name                  = each.value.azure_devops.service_connection_name
  description                            = "${each.value.azure_devops.service_connection_name}: Managed by Terraform"
  service_endpoint_authentication_scheme = "WorkloadIdentityFederation"

  credentials {
    serviceprincipalid = each.value.azure_devops.user_assigned_identity_client_id
  }

  azurerm_spn_tenantid      = var.azurerm_spn_tenantid
  azurerm_subscription_id   = var.azurerm_subscription_id
  azurerm_subscription_name = var.azurerm_subscription_name
}

resource "azuredevops_check_required_template" "this" {
  for_each             = var.environments
  project_id           = local.project_id
  target_resource_id   = azuredevops_serviceendpoint_azurerm.this[each.key].id
  target_resource_type = "endpoint"

  dynamic "required_template" {
    for_each = each.value.azure_devops.service_connection_required_templates
    content {
      repository_type = "azuregit"
      repository_name = "${var.project_name}/${var.templates_repository_name}"
      repository_ref  = local.default_branch
      template_path   = required_template.value
    }
  }
}

resource "azuredevops_check_exclusive_lock" "this" {
  for_each             = var.environments
  project_id           = local.project_id
  target_resource_id   = azuredevops_serviceendpoint_azurerm.this[each.key].id
  target_resource_type = "endpoint"
  timeout              = 43200
}

resource "azuredevops_check_approval" "this" {
  for_each = (
    length(local.approvers) != 0
    ? { for key, env in var.environments : key => env if env.azure_devops.enable_check_approval }
    : {}
  )
  project_id            = local.project_id
  target_resource_id    = azuredevops_serviceendpoint_azurerm.this[each.key].id
  target_resource_type  = "endpoint"
  requester_can_approve = length(local.approvers) == 1
  timeout               = 43200
  approvers = [
    azuredevops_group.approver_group.origin_id
  ]
}
