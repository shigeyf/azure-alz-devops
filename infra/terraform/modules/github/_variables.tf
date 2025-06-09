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
