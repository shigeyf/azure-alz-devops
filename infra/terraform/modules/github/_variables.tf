// _variables.tf

variable "organization_name" {
  description = "Name of the GitHub organization"
  type        = string
}

variable "organization_domain_name" {
  description = "Domain name of the GitHub organization"
  type        = string
  default     = "github.com"
}

variable "api_domain_name" {
  description = "Domain name of your GitHub API endpoint"
  type        = string
  default     = "api.github.com"
}

variable "approvers_group" {
  description = "Name of the CI/CD approvers group"
  type = object({
    name      = string
    approvers = optional(list(string), [])
  })
}

variable "variables" {
  description = "Variables defined in the GitHub Actions"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}
