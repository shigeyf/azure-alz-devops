// _locals.pipeline.tf

locals {
  # tflint-ignore: terraform_unused_declarations
  pipeline_keys = [
    var.ci_pipeline_key,
    var.cd_pipeline_key,
  ]

  pipelines = {
    for key, value in var.pipelines
    : key => {
      name = value.pipeline_name
      file = azuredevops_git_repository_file.this[value.pipeline_file_name].file
      environments = [
        for env_key in value.environment_keys : {
          key = "${key}-${env_key}"
          id  = azuredevops_environment.this[env_key].id
        }
      ]
      service_connections = [
        for sc_key in value.service_connection_keys : {
          key = "${key}-${sc_key}"
          id  = azuredevops_serviceendpoint_azurerm.this[sc_key].id
        }
      ]
    }
  }
}
