// _locals.vars.tf

locals {
  tfstate_backend_variables = [
    { name = "BACKEND_AZURE_RESOURCE_GROUP_NAME", value = local.bootstrap.resource_group_name },
    { name = "BACKEND_AZURE_STORAGE_ACCOUNT_NAME", value = local.bootstrap.storage_account_name },
    { name = "BACKEND_AZURE_STORAGE_ACCOUNT_CONTAINER_NAME", value = "${var.project_name}-tfstate" },
    { name = "LOG_AZURE_STORAGE_ACCOUNT_CONTAINER_NAME", value = "${var.project_name}-log" },
  ]
}

locals {
  azure_subscription_variables = [
    { name = "AZURE_TENANT_ID", value = data.azurerm_client_config.current.tenant_id },
  ]
}
