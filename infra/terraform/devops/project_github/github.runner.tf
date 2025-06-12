// github.runner.tf

locals {
  runners = (var.use_self_hosted_runners
    ? [
      {
        event_job_name                 = local.container_app_job_name
        replica_timeout                = 3600
        replica_retry_limit            = 3
        event_parallelism              = 1
        event_replica_completion_count = 1
        workload_profile_name          = local.container_app_workload_profile_name
        registry = [
          {
            server   = local.acr_login_server
            identity = local.container_run_managed_identity_id
          }
        ]
        template = {
          container = [local.container_specs.github_runner_aca.container.aca_agent_job.container]
        }
        secret = local.container_specs.github_runner_aca.container.aca_agent_job.secrets
        event_scale = {
          max_executions   = 10
          min_executions   = 0
          polling_interval = 10
          rules            = [local.container_specs.github_runner_aca.container.aca_agent_job.scale_rules]
        }
      }
    ]
    : []
  )
}

module "runner" {
  count                             = var.use_self_hosted_runners ? 1 : 0
  source                            = "../../modules/aca_event_job"
  resource_group_name               = local.agents_resource_group_name
  location                          = var.location
  tags                              = var.tags
  container_app_environment_id      = local.container_app_environment_id
  container_run_managed_identity_id = local.container_run_managed_identity_id
  event_jobs                        = local.runners
}

// For Debug
output "runners" {
  value = local.runners
}
