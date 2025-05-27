// _variables.vcs.github.tf

variable "enable_github" {
  description = "Enable GitHub"
  type        = bool
  default     = false
}

variable "github_organization_name" {
  description = "GitHub organization name"
  type        = string

  validation {
    condition     = var.enable_github == false ? true : var.github_organization_name != ""
    error_message = "GitHub organization name must be not null string"
  }
}

variable "github_enterprise_name" {
  description = "GitHub enterprise name"
  type        = string
  default     = ""
}

variable "github_personal_access_token_for_runners" {
  description = "GitHub PAT (Personal Access Token) for the Self-Hosted Runners"
  type        = string
  default     = ""

  validation {
    condition     = var.enable_github == false ? true : var.github_personal_access_token_for_runners != ""
    error_message = "GitHub PAT (Personal Access Token) must be not null string"
  }
}
