// _variables.environment.tf

variable "default_environments" {
  description = "Default environments to be created"
  type        = map(string)
  default     = {}
}

variable "environments" {
  description = "Environments to be created"
  type = map(object({
    branch_policy_branch_patterns = optional(list(string), [])
    branch_policy_tag_patterns    = optional(list(string), [])
    can_admins_bypass             = optional(bool, false)
    custom_branch_policies        = optional(bool, false)
    environment                   = string
    name                          = string
    prevent_self_review           = optional(bool, false)
    protected_branches            = optional(bool, false)
    reviewers                     = optional(list(string), [])
    variables                     = optional(list(object({ name = string, value = string })), [])
    wait_timer                    = optional(number, 0)
  }))
  default = {}
}
