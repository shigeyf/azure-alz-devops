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

variable "naming_suffix" {
  description = "Resource naming suffix for the deployed resources"
  type        = list(string)
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

variable "enable_private_network" {
  description = "Enable private network for the self-hosted agent resources"
  type        = bool
  default     = false
}

variable "enable_self_hosted_agents" {
  description = "Enable self-hosted agents"
  type        = bool
  default     = false
}
