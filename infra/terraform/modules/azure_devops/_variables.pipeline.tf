// _variables.pipeline.tf

variable "ci_pipeline_key" {
  description = "Key for the CI pipeline"
  type        = string
}

variable "cd_pipeline_key" {
  description = "Key for the CD pipeline"
  type        = string
}

variable "pipelines" {
  type = map(object({
    pipeline_name           = string
    pipeline_file_name      = string
    environment_keys        = list(string)
    service_connection_keys = list(string)
  }))
}
