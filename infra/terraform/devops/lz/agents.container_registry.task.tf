// container_registry.task.tf

locals {
  tasks = local.container_image_build_tasks
}

resource "azurerm_container_registry_task" "acr_task" {
  for_each              = local.enable_agents_resources ? local.tasks : {}
  container_registry_id = module.acr[0].output.acr_id
  name                  = each.value.task_name
  tags                  = var.tags

  docker_step {
    context_access_token = "a" # dummy
    context_path         = each.value.context_path
    dockerfile_path      = each.value.dockerfile_path
    image_names          = each.value.image_names
  }

  platform {
    os = each.value.platform_os
  }
  identity {
    type = "SystemAssigned"
  }
  registry_credential {
    custom {
      login_server = module.acr[0].output.acr_login_server
      identity     = "[system]"
    }
  }

  depends_on = [
    module.acr,
    module.azuredevops_agent_aca,
    module.github_runner_aca,
    #module.azuredevops_aci,
    #module.github_aci,
  ]
}

resource "azurerm_role_assignment" "acr_task_ra_acr_push" {
  for_each             = local.enable_agents_resources ? local.tasks : {}
  principal_id         = azurerm_container_registry_task.acr_task[each.key].identity[0].principal_id
  scope                = module.acr[0].output.acr_id
  role_definition_name = "AcrPush"

  depends_on = [
    module.acr,
    azurerm_container_registry_task.acr_task,
  ]
}

resource "azurerm_container_registry_task_schedule_run_now" "acr_task" {
  for_each                   = local.enable_agents_resources ? local.tasks : {}
  container_registry_task_id = azurerm_container_registry_task.acr_task[each.key].id
  lifecycle {
    replace_triggered_by = [azurerm_container_registry_task.acr_task]
  }

  depends_on = [
    azurerm_role_assignment.acr_task_ra_acr_push,
    azurerm_container_registry_task.acr_task,
  ]
}
