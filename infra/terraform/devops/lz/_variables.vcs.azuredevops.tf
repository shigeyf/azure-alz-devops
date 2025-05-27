// _variables.vcs.azuredevops.tf

variable "enable_azuredevops" {
  description = "Enable Azure DevOps"
  type        = bool
  default     = false
}

variable "azuredevops_organization_name" {
  description = "Azure DevOps organization name"
  type        = string
  default     = ""

  validation {
    condition     = var.enable_azuredevops == false ? true : var.azuredevops_organization_name != ""
    error_message = "Azure DevOps organization name must be not null string"
  }
}

variable "azuredevops_personal_access_token_for_agents" {
  description = "Azure DevOps PAT (Personal Access Token) for the Self-Hosted Agent"
  type        = string
  default     = ""

  validation {
    condition     = var.enable_azuredevops == false ? true : var.azuredevops_personal_access_token_for_agents != ""
    error_message = "Azure DevOps PAT (Personal Access Token) must be not null string"
  }
}
