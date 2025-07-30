// _variables.keyvault.tf

variable "keyvault_name" {
  description = "Name of the Key Vault"
  type        = string
}

variable "enabled_for_deployment" {
  description = "Enable deployment"
  type        = bool
  default     = false
}
variable "enabled_for_disk_encryption" {
  description = "Enable disk encryption"
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "Enable template deployment"
  type        = bool
  default     = false
}
variable "purge_protection_enabled" {
  description = "Enable purge protection"
  type        = bool
  default     = true
}
variable "soft_delete_retention_days" {
  description = "Soft delete retention days"
  type        = number
  default     = 7
}
