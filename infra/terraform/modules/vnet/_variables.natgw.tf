// _variables.natgw.tf

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = false
}

variable "nat_gateway_name" {
  description = "NAT Gateway name"
  type        = string
  default     = null

  validation {
    condition     = !(var.enable_nat_gateway && var.nat_gateway_name == null)
    error_message = "'nat_gateway_name' must be set if 'enable_nat_gateway' is enabled."
  }
}

variable "nat_gateway_public_ip_name" {
  description = "NAT Gateway Public IP name"
  type        = string
  default     = null

  validation {
    condition     = !(var.enable_nat_gateway && var.nat_gateway_public_ip_name == null)
    error_message = "'nat_gateway_public_ip_name' must be set if 'enable_nat_gateway' is enabled."
  }
}
