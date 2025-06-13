// _variables.tf

variable "target_subscription_id" {
  description = "Azure Subscription Id for the DevOps resources. Leave empty to use the az login subscription"
  type        = string
  default     = ""

  validation {
    condition     = var.target_subscription_id == "" ? true : can(regex("^[0-9a-fA-F-]{36}$", var.target_subscription_id))
    error_message = "Azure subscription id must be a valid GUID"
  }
}

variable "role_propagation_time" {
  type        = string
  description = "Wait seconds to propagate role assignments"
  default     = "60s"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "location" {
  description = "Azure region for the deployment"
  type        = string
}

variable "tags" {
  description = "Tags for the deployed resources"
  type        = map(string)
  default     = {}
}

variable "subscriptions" {
  description = "Map of Azure subscriptions for the project by environment"
  type = map(object({
    id = string
  }))
  default = {}
}

variable "use_templates_repository" {
  description = "Whether to use a separate repository for templates"
  type        = bool
  default     = true
}

variable "use_runner_group" {
  description = "Whether to use a GitHub Runner Group"
  type        = bool
  default     = false
}

variable "use_self_hosted_runners" {
  description = "Enable self-hosted runners"
  type        = bool
  default     = true

  validation {
    condition     = var.use_self_hosted_runners == false && local.options.private_network_enabled == false || var.use_self_hosted_runners == true && local.options.self_hosted_enabled == true
    error_message = "Self-hosted GitHub Runners can only be enabled if the 'self_hosted_enabled' option in the DevOps deployment configuration is true, and Self-hosted GitHub Runners cannot be enabled if the 'private_network_enabled' option is true."
  }
}

variable "self_hosted_runners_type" {
  description = "Type of self-hosted runners to use"
  type        = string
  default     = "aca"

  validation {
    condition     = var.self_hosted_runners_type == "aci" || var.self_hosted_runners_type == "aca"
    error_message = "Self-hosted runners type must be either 'aci' or 'aca'."
  }
}
