// container_app_environment.tf

locals {
  # Terraform AzureRM ~2.4.30
  # This logic is for a bug on 'infrastructure_resource_group_name' property
  _location = lower(replace(var.location, " ", ""))
  infrastructure_resource_group_name = (
    var.container_app_infra_resource_group_name != null
    ? var.container_app_infra_resource_group_name
    : "ME_${var.container_app_environment_name}_${var.resource_group_name}_${local._location}"
  )
}

resource "azurerm_container_app_environment" "this" {
  name                       = var.container_app_environment_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tags                       = var.tags
  logs_destination           = var.logs_destination
  log_analytics_workspace_id = var.log_analytics_workspace_id

  infrastructure_resource_group_name = var.container_app_subnet_id != null ? local.infrastructure_resource_group_name : null
  infrastructure_subnet_id           = var.container_app_subnet_id
  internal_load_balancer_enabled     = var.container_app_subnet_id != null ? var.internal_load_balancer_enabled : null
  zone_redundancy_enabled            = var.container_app_subnet_id != null ? var.zone_redundancy_enabled : null

  workload_profile {
    name                  = var.workload_profile_name
    workload_profile_type = var.workload_profile_type
    maximum_count         = var.workload_maximum_count
    minimum_count         = var.workload_minimum_count
  }

  depends_on = [
    azurerm_resource_provider_registration.this,
  ]
}
