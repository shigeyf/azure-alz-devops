// instances.tf

data "azurerm_key_vault_secret" "secure_environment_variables" {
  for_each = {
    for senv in var.container_instance_spec.container.secure_environment_variables :
    senv.name => senv.value if senv.value != null && senv.value != ""
  }
  name         = element(reverse(split("/", each.value)), 0)
  key_vault_id = var.keyvault_id
}

data "azurerm_log_analytics_workspace" "this" {
  name                = element(reverse(split("/", var.log_analytics_workspace_id)), 0)
  resource_group_name = element(split("/", var.log_analytics_workspace_id), 4)
}

locals {
  _environment_variables_map = {
    for env in var.container_instance_spec.container.environment_variables
    : env.name => env.value
    if env.value != null && env.value != ""
  }
  _secure_environment_variables_map = {
    for name, kvsenv in data.azurerm_key_vault_secret.secure_environment_variables
    : name => kvsenv.value
    if kvsenv.value != null && kvsenv.value != ""
  }
}

locals {
  _container_instances = {
    for instance in range(0, var.container_instance_count) :
    instance => {
      name = "${var.container_instance_name}-${format("%03d", instance + 1)}"
      environment_variables = merge(
        {
          for key, value in local._environment_variables_map
          : key => replace(value, "{index}", format("%03d", instance + 1))
          if strcontains(value, "{index}")
        },
        {
          for key, value in local._environment_variables_map
          : key => value
          if !strcontains(value, "{index}")
        }
      )
    }
  }
}

resource "azurerm_container_group" "this" {
  for_each            = local._container_instances
  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  sku             = var.container_instance_sku
  ip_address_type = var.container_instance_enable_private_network ? "Private" : "None"
  subnet_ids      = var.container_instance_enable_private_network ? [var.container_instance_subnet_id] : []
  zones           = var.container_instance_availability_zones

  identity {
    type         = "UserAssigned"
    identity_ids = [var.container_run_managed_identity_id]
  }

  image_registry_credential {
    server                    = var.acr_login_server
    user_assigned_identity_id = var.container_run_managed_identity_id
  }

  os_type = var.container_instance_spec.os_type
  container {
    name                         = var.container_instance_spec.container.name
    image                        = "${var.acr_login_server}/${var.container_instance_spec.container.image_name}"
    cpu                          = var.container_instance_spec.container.cpu
    memory                       = var.container_instance_spec.container.memory
    cpu_limit                    = var.container_instance_spec.container.cpu_limit
    memory_limit                 = var.container_instance_spec.container.memory_limit
    environment_variables        = each.value.environment_variables
    secure_environment_variables = local._secure_environment_variables_map

    dynamic "ports" {
      for_each = var.container_instance_spec.container.ports
      content {
        port     = ports.value.port
        protocol = ports.value.protocol
      }
    }
  }

  diagnostics {
    log_analytics {
      workspace_id  = data.azurerm_log_analytics_workspace.this.workspace_id
      workspace_key = data.azurerm_log_analytics_workspace.this.primary_shared_key
    }
  }

  depends_on = [
    data.azurerm_key_vault_secret.secure_environment_variables,
    data.azurerm_log_analytics_workspace.this,
  ]
}
