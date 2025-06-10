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

variable "devops_tfstate_key" {
  description = "Key for the Terraform state in Azure DevOps"
  type        = string
  default     = "devopslz.terraform.tfstate"
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
  default     = false
}

variable "role_propagation_time" {
  type        = string
  description = "Wait seconds to propagate role assignments"
  default     = "60s"
}
