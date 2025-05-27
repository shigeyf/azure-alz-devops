// _variables.bootstrap.tf

variable "bootstrap_config_filename" {
  description = "Path to the bootstrap config file"
  type        = string
  default     = "../../_bootstrap/bootstrap.config.json"
}
