// _variables.tf

variable "location" {
  description = "Azure region for the deployment"
  type        = string
}

variable "tags" {
  description = "Tags for the deployed resources"
  type        = map(string)
  default     = {}
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "bootstrap_config_filename" {
  description = "Path to the bootstrap output file"
  type        = string
  default     = "./bootstrap.config.json"
}

variable "bootstrap_backend_filename" {
  description = "Path to the bootstrap backend Terraform file"
  type        = string
  default     = "./backend.tf"
}

variable "tfbackend_config_template_filename" {
  description = "Path to the backend config template file"
  type        = string
  default     = "./azurerm.tfbackend"
}
