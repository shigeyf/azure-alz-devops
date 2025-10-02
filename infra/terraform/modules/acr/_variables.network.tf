// _variables.network.tf

variable "enable_public_network_access" {
  description = "Enable public network access"
  type        = bool
  default     = true

  validation {
    condition     = var.export_policy_enabled || (var.export_policy_enabled == false && var.enable_public_network_access == false)
    error_message = "'enable_public_network_access' must be set to disabled if 'export_policy_enabled' is disabled."
  }
}

variable "override_public_network_access" {
  description = "Override a configuration for `enable_public_network_access`"
  type        = bool
  default     = false
}

variable "network_resource_group_name" {
  description = "Resource Group name for Network related resources (pre-generated resource group)"
  type        = string
  default     = null
}

variable "private_endpoint_name" {
  description = "Private Endpoint name"
  type        = string
  default     = null

  validation {
    condition     = !(!var.enable_public_network_access && var.private_endpoint_name == null)
    error_message = "'private_endpoint_name' must be set if 'enable_public_network_access' is disabled."
  }
}

variable "private_endpoint_subnet_id" {
  description = "Private Endpoint Subnet Id"
  type        = string
  default     = null

  validation {
    condition     = !(!var.enable_public_network_access && var.private_endpoint_subnet_id == null)
    error_message = "'private_endpoint_subnet_id' must be set if 'enable_public_network_access' is disabled."
  }
}

variable "private_dns_zone_ids" {
  type        = list(string)
  description = "List of Private DNS Zone Id"
  default     = []
}
