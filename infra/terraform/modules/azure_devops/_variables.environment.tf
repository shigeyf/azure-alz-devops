// _variables.environment.tf

variable "environments" {
  description = "Environments to be created"
  type = map(object({
    name        = string
    description = string
    azure_devops = object({
      service_connection_name               = string
      user_assigned_identity_client_id      = string
      service_connection_required_templates = list(string)
      enable_check_approval                 = bool
    })
    github = optional(any, {})
  }))
  default = {}
}
