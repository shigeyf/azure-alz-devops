// _variables.repo.tf

variable "main_repository_name" {
  description = "Name of the Azure DevOps repository for main"
  type        = string
}

variable "templates_repository_name" {
  description = "Name of the Azure DevOps repository for templates"
  type        = string
}

variable "use_templates_repository" {
  description = "Whether to use a separate repository for GitHub Actions workflow templates"
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

variable "variables" {
  description = "Variables defined in the GitHub Actions"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "branch_rules" {
  description = "Branch protection rules for the repository"
  type = map(object({
    name        = string
    branch_name = string
    description = string
    rules = object({
      creation                      = optional(bool, false)
      deletion                      = optional(bool, true)
      update                        = optional(bool, false)
      non_fast_forward              = optional(bool, true)
      required_linear_history       = optional(bool, false)
      required_signatures           = optional(bool, false)
      update_allows_fetch_and_merge = optional(bool, false)

      pull_request = optional(object({
        dismiss_stale_reviews_on_push     = optional(bool, false)
        require_code_owner_review         = optional(bool, false)
        require_last_push_approval        = optional(bool, false)
        required_approving_review_count   = optional(number, 0)
        required_review_thread_resolution = optional(bool, false)
      }))

      required_deployments = optional(object({
        required_deployment_environments = list(string)
      }))

      required_status_checks = optional(object({
        do_not_enforce_on_create             = optional(bool, false)
        strict_required_status_checks_policy = optional(bool, false)
        required_checks = list(object({
          context        = string
          integration_id = optional(number)
        }))
      }))
    })
  }))
  default = {}
}
