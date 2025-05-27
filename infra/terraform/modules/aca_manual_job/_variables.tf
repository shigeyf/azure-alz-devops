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

variable "container_app_environment_id" {
  description = "Container App Environment Id"
  type        = string
}

variable "container_run_managed_identity_id" {
  type        = string
  description = "The principal id of the managed identity used by the container execution"
}
