// _outputs.tf

locals {
  _container_image_name = "${var.container_image_name}:${var.container_src_repo_tag}"
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

    aci = {
      os_type = var.container_platform_os
      container = {
        name         = var.container_image_name
        image        = local._container_image_name
        cpu          = var.container_cpu
        memory       = var.container_memory
        cpu_limit    = var.container_cpu_limit
        memory_limit = var.container_memory_limit
        ports = [
          {
            port     = 80
            protocol = "TCP"
          }
        ]
        environment_variables = [
          for v in local.environment_variables : { name = v.name, value = v.value } if v.secret == false
        ]
        secure_environment_variables = [
          for v in local.environment_variables : { name = v.name, value = v.value } if v.secret == true
        ]
      }
    }
  }
}
