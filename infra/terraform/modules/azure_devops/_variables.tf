// variables.tf

variable "use_legacy_organization_url" {
  description = "Whether to use the legacy organization URL format (https://{organization_name}.visualstudio.com)"
  type        = bool
  default     = false
}

variable "organization_name" {
  description = "Name of the Azure DevOps organization"
  type        = string
}

variable "create_project" {
  description = "Whether to create a new Azure DevOps project"
  type        = bool
  default     = true
}

variable "approvers_group" {
  description = "Name of the CI/CD approvers group"
  type = object({
    name      = string
    approvers = optional(list(string), [])
  })
}

variable "variable_group_name" {
  description = "Name of the Variable Group"
  type        = string
}

variable "variables" {
  description = "Variables defined in the Variable Group"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}
