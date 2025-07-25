// _variables.bootstrap.tf

variable "bootstrap_config_filename" {
  description = "Path to the bootstrap config file"
  type        = string
  default     = "../../_bootstrap/bootstrap.config.json"
}

variable "devops_tfstate_key" {
  description = "Key for the Terraform state in Azure DevOps"
  type        = string
  default     = "devopslz.terraform.tfstate"
}
