// _variables.environment.tf

variable "environments" {
  description = "Environments to be created"
  type = map(object({
    name         = string
    description  = string
    azure_devops = optional(any, {})
    github = object({
      enable_reviewers                 = bool
      enable_deployment_branch_policy  = bool
      user_assigned_identity_client_id = string
    })
  }))
  default = {}
}
