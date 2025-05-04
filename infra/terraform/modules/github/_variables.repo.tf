// _variables.repo.tf

variable "main_repository_name" {
  description = "Name of the Azure DevOps repository for main"
  type        = string
}

variable "templates_repository_name" {
  description = "Name of the Azure DevOps repository for templates"
  type        = string
}

variable "use_separate_repo_for_pipeline_templates" {
  description = "Whether to use a separate repository for pipeline templates"
  type        = bool
  default     = false
}

variable "main_repository_files" {
  description = "Map of files to be created in the repository"
  type        = map(object({ content = string }))
  default     = {}
}

variable "templates_repository_files" {
  description = "Map of files to be created in the templates repository"
  type        = map(object({ content = string }))
  default     = {}
}

variable "create_branch_policies" {
  description = "Whether to create branch policies"
  type        = bool
  default     = false
}
