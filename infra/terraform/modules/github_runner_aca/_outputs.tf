// _outputs.tf

locals {
  _container_image_name  = "${var.container_image_name}:${var.container_src_repo_tag}"
  _keda_scaler_rule_type = "github-runner"

  _secrets = [
    for v in local.environment_variables : {
      name                = v.value,
      identity            = var.secret_reader_uami_id,
      key_vault_secret_id = v.kv_secret_id
    } if v.secret == true
  ]

  _keda_scaler_rule = {
    name             = local._keda_scaler_rule_type
    custom_rule_type = local._keda_scaler_rule_type
    metadata = merge(
      { for v in local.environment_variables : (v.keda_metadata) => v.value if v.keda_metadata != "" && v.secret == false },
      { "targetWorkflowQueueLength" = "1" },
    )
    authentication = [
      for v in local.environment_variables : {
        secret_name       = v.value,
        trigger_parameter = v.keda_metadata,
      } if v.keda_metadata != "" && v.secret == true
    ]
  }
}

output "container" {
  value = {
    registry_task = {
      name            = replace(var.container_image_name, "-", "_")
      task_name       = "${var.container_image_name}-image-build-task"
      dockerfile_path = var.container_src_docker_file
      context_path    = "${var.container_src_repo_url}#${var.container_src_repo_tag}:${var.container_src_docker_root}"
      image_names     = [local._container_image_name]
      platform_os     = var.container_platform_os
    }

    aca_agent_job = {
      container = {
        name   = var.container_image_name
        cpu    = var.container_cpu
        memory = "${var.container_memory}Gi"
        image  = "${var.acr_login_server}/${local._container_image_name}"
        env = concat(
          [for v in local.environment_variables : { name = v.name, secret_name = v.value } if v.secret == true],
          [for v in local.environment_variables : { name = v.name, value = v.value } if v.secret == false],
        )
      }
      scale_rules = local._keda_scaler_rule
      secrets     = local._secrets
    }
  }
}
