// container_app_job.manual.tf

resource "azurerm_container_app_job" "manual" {
  for_each                     = { for key, job in nonsensitive(var.manual_jobs) : key => job }
  name                         = each.value.manual_job_name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  tags                         = var.tags
  container_app_environment_id = var.container_app_environment_id

  identity {
    type         = "UserAssigned"
    identity_ids = [var.container_run_managed_identity_id]
  }

  replica_timeout_in_seconds = each.value.replica_timeout
  replica_retry_limit        = each.value.replica_retry_limit
  workload_profile_name      = each.value.workload_profile_name

  manual_trigger_config {
    parallelism              = each.value.manual_parallelism
    replica_completion_count = each.value.manual_replica_completion_count
  }

  dynamic "registry" {
    for_each = [for r in each.value.registry : r]
    content {
      server   = registry.value.server
      identity = registry.value.identity
    }
  }

  dynamic "secret" {
    for_each = [for s in each.value.secret : s]
    content {
      name                = secret.value.name
      identity            = secret.value.identity
      key_vault_secret_id = secret.value.key_vault_secret_id
      value               = secret.value.value
    }
  }

  template {
    dynamic "container" {
      for_each = [for c in each.value.template.container : c]
      content {
        name   = container.value.name
        cpu    = container.value.cpu
        memory = container.value.memory
        image  = container.value.image
        dynamic "env" {
          for_each = [for e in container.value.env : e]
          content {
            name        = env.value.name
            value       = env.value.value
            secret_name = env.value.secret_name
          }
        }
      }
    }
  }
}
