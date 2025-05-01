// _variables.bootstrap.tf

variable "bootstrap_config_filename" {
  description = "Path to the bootstrap output file"
  type        = string
  default     = "./bootstrap.config.json"
}

variable "tfbackend_config_template_filename" {
  description = "Path to the backend config template file"
  type        = string
  default     = "./azurerm.tfbackend"
}
