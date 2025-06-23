// _locals.tf

locals {
  _project_name  = lower(var.project_name)
  _resource_name = "${local._project_name}-${local.location_short_name}"
  resource_name  = length(local._resource_name) > 16 ? substr(local._resource_name, 0, 16) : local._resource_name
  project_suffix = join("-", concat([local._project_name], ["devops"], [local.location_short_name]))

  // For Project repository
  repository_name           = local._project_name
  templates_repository_name = "${local._project_name}-templates"
  uami_name_prefix          = "uami-${substr(module.naming.user_assigned_identity.name, 4, -1)}-${local.rand_id}-"
  runner_scope              = var.use_runner_group ? "org" : "repo"
  runner_group_name         = var.use_runner_group ? "runner-group-${local._project_name}" : ""
  runner_scope_name         = var.use_runner_group ? local.options.github.organization_name : "${local.options.github.organization_name}/${local._project_name}"

  // For Self-Hosted GitHub Actions Runners
  container_app_job_name  = "cajob-${local.resource_name}-ghr-${local.rand_id}"
  container_instance_name = "aci-${local.resource_name}-ghr-${local.rand_id}"

  // For DevBox Project
  devbox_project_name        = "dbp-${local.project_suffix}-${local.rand_id}"
  devbox_project_pool_prefix = "DevBoxPool-${var.project_name}-"
}
