// _variables.tf

variable "organization_name" {
  description = "Name of the GitHub organization"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "repository_name" {
  description = "Name of the GitHub repository name"
  type        = string
}

variable "templates_repository_name" {
  description = "Name of the GitHub templates repository name"
  type        = string
}

variable "templates_ref" {
  description = "Ref name of the GitHub templates repository for template files"
  type        = string
  default     = "main"
}

variable "use_templates_repository" {
  description = "Whether to use a separate repository for templates"
  type        = bool
  default     = false
}

variable "runner_group_name" {
  description = "Name of the GitHub Runner"
  type        = string
  default     = ""
}
