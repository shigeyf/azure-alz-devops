// _variables.bootstrap.tf

variable "bootstrap_config_filename" {
  description = "Path to the bootstrap config file"
  type        = string
  default     = "./bootstrap.config.json"
}

variable "tfbackend_config_template_filename" {
  description = "Path to the backend config template file"
  type        = string
  default     = "./devops.azurerm.tfbackend"
}
