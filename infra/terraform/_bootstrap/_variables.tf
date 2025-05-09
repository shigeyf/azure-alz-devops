// _variables.tf

variable "target_subscription_id" {
  description = "Azure Subscription Id for the bootstrap resources. Leave empty to use the az login subscription"
  type        = string
  default     = ""

  validation {
    condition = (
      var.target_subscription_id == ""
      || can(regex(
        "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$",
        var.target_subscription_id,
      ))
    )
    error_message = "Azure subscription id must be a valid GUID"
  }
}

variable "naming_suffix" {
  description = "Resource naming suffix for the deployed resources"
  type        = list(string)
  default     = ["alz", "devops", "bootstrap"]
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

variable "tfstate_container_name" {
  description = "Name of the storage container storing Terraform state files"
  type        = string
  default     = "tfstate"
}

variable "enable_user_assigned_identity" {
  description = "Enable User-assigned Identity for the storage account"
  type        = bool
  default     = false
}

variable "enable_storage_customer_managed_key" {
  description = "Enable Customer Managed Key for the storage account"
  type        = bool
  default     = false
}

variable "customer_managed_key_policy" {
  description = "Key policy for Customer Managed Key"
  type = object({
    key_type        = string
    key_size        = optional(number)
    curve_type      = optional(string)
    expiration_date = optional(string, null)
    rotation_policy = optional(object({
      automatic = optional(object({
        time_after_creation = optional(string)
        time_before_expiry  = optional(string)
      }))
      expire_after         = optional(string)
      notify_before_expiry = optional(string)
    }))
  })
  default = {
    key_type = "RSA"
    key_size = 2048
    rotation_policy = {
      automatic = {
        time_before_expiry = "P30D"
      }
      expire_after         = "P90D"
      notify_before_expiry = "P29D"
    }
  }
}
