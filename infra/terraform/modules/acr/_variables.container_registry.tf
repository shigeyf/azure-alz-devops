// variables.container_registry.tf

variable "container_registry_name" {
  type        = string
  description = "Name of the container registry"
}

variable "sku" {
  type        = string
  description = "SKU name of the container registry"
  default     = "Basic"
  // Possible values are Basic, Standard and Premium

  validation {
    condition     = var.enable_public_network_access || (!var.enable_public_network_access && var.sku == "Premium")
    error_message = "'sku' must be set to 'Premium' if 'enable_public_network_access' is disabled."
  }
}

variable "admin_enabled" {
  type        = bool
  description = "Specifies whether the admin user is enabled"
  default     = false
}

variable "network_rule_bypass_option" {
  type        = string
  description = "Whether to allow trusted Azure services to access a network restricted Container Registry"
  default     = "AzureServices"
  // Possible values are AzureServices and None
}

variable "export_policy_enabled" {
  type        = bool
  description = "Specifies whether the export policy is enabled"
  default     = true
}

variable "enable_user_assigned_identity" {
  type        = bool
  description = "Enable user-assigned managed identity"
  default     = false
}

variable "acr_uami_name" {
  type        = string
  description = "User-assigned managed identity name"
  default     = null

  validation {
    condition     = !(var.enable_user_assigned_identity && var.acr_uami_name == null)
    error_message = "'acr_uami_name' must be set if 'enable_user_assigned_identity' is enabled."
  }
}

variable "enable_customer_managed_key" {
  type        = bool
  description = "Enable encryption with customer managed key (your own key)"
  default     = false

  validation {
    condition     = !var.enable_customer_managed_key || (var.enable_customer_managed_key && var.enable_user_assigned_identity)
    error_message = "'enable_user_assigned_identity' must be enabled if 'enable_customer_managed_key' is enabled."
  }

  validation {
    condition     = !var.enable_customer_managed_key || (var.enable_customer_managed_key && var.sku == "Premium")
    error_message = "'sku' must be set to 'Premium' if 'enable_customer_managed_key' is enabled."
  }
}

variable "keyvault_id" {
  type        = string
  description = "Key Vault ID for encryption"
  default     = null

  validation {
    condition     = !(var.enable_customer_managed_key && var.keyvault_id == null)
    error_message = "'keyvault_id' must be set if 'enable_customer_managed_key' is enabled."
  }
}

variable "key_vault_key_id" {
  type        = string
  description = "Key Vault key ID for encryption"
  default     = null

  validation {
    condition     = !(var.enable_customer_managed_key && var.key_vault_key_id == null)
    error_message = "'key_vault_key_id' must be set if 'enable_customer_managed_key' is enabled."
  }
}
