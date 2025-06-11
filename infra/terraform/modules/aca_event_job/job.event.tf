// container_app_job.event.tf

resource "azurerm_container_app_job" "event" {
  for_each                     = { for key, job in nonsensitive(var.event_jobs) : key => job }
  name                         = each.value.event_job_name
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

  event_trigger_config {
    parallelism              = each.value.event_parallelism
    replica_completion_count = each.value.event_replica_completion_count
    dynamic "scale" {
      for_each = each.value.event_scale != null ? [each.value.event_scale] : []
      content {
        max_executions              = scale.value.max_executions
        min_executions              = scale.value.min_executions
        polling_interval_in_seconds = scale.value.polling_interval
        dynamic "rules" {
          for_each = scale.value.rules != null ? scale.value.rules : []
          content {
            name             = rules.value.name
            custom_rule_type = rules.value.custom_rule_type
            metadata         = rules.value.metadata
            dynamic "authentication" {
              for_each = rules.value.authentication != null ? rules.value.authentication : []
              content {
                secret_name       = authentication.value.secret_name
                trigger_parameter = authentication.value.trigger_parameter
              }
            }
          }
        }
      }
    }
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
