// _variables.tf

variable "resource_group_name" {
  description = "Name of the resource group"
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

variable "acr_login_server" {
  description = "Azure Container Registry login server URL"
  type        = string
}

variable "container_run_managed_identity_id" {
  description = "User-assigned Managed Identity used by the container execution"
  type        = string
}

variable "keyvault_id" {
  description = "Key Vault Id for storing secure environment variables"
  type        = string
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace Id"
  default     = null
}
