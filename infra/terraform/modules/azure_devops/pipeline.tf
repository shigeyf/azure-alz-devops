// pipeline.tf

# Pipelines
resource "azuredevops_build_definition" "this" {
  for_each   = local.pipelines
  project_id = local.project_id
  name       = each.value.name

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.this.id
    branch_name = azuredevops_git_repository.this.default_branch
    yml_path    = each.value.file
  }
}

#
# Environment mapping for pipelines
#
locals {
  _pipeline_environment_map = flatten([
    for key, pipeline in local.pipelines
    : [
      for env in pipeline.environments
      : {
        key            = env.key
        environment_id = env.id
        pipeline_id    = azuredevops_build_definition.this[key].id
      }
    ]
  ])
}

resource "azuredevops_pipeline_authorization" "environment" {
  for_each    = { for env in local._pipeline_environment_map : env.key => env }
  project_id  = local.project_id
  resource_id = each.value.environment_id
  type        = "environment"
  pipeline_id = each.value.pipeline_id
}

#
# Service Connections mapping for pipelines
#
locals {
  _pipeline_service_connection_map = flatten([
    for key, pipeline in local.pipelines
    : [
      for sc in pipeline.service_connections
      : {
        key                   = sc.key
        service_connection_id = sc.id
        pipeline_id           = azuredevops_build_definition.this[key].id
      }
    ]
  ])
}

resource "azuredevops_pipeline_authorization" "service_connection" {
  for_each    = { for sc in local._pipeline_service_connection_map : sc.key => sc }
  project_id  = local.project_id
  resource_id = each.value.service_connection_id
  type        = "endpoint"
  pipeline_id = each.value.pipeline_id
}


#
# Agent Pool Queue mapping for pipelines
#
resource "azuredevops_pipeline_authorization" "alz_agent_pool" {
  for_each    = var.use_self_hosted_agents ? local.pipelines : {}
  project_id  = local.project_id
  resource_id = azuredevops_agent_queue.this[0].id
  type        = "queue"
  pipeline_id = azuredevops_build_definition.this[each.key].id
}
