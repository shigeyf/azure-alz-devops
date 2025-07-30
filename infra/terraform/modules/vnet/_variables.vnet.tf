// _variables.vnet.tf

variable "vnet_name" {
  description = "Virtual network name"
  type        = string
}

variable "address_prefix" {
  description = "Address prefix for the virtual network"
  type        = string
}

variable "nsg_name_prefix" {
  description = "Network Security Group name prefix"
  type        = string
  default     = "nsg"
}

variable "subnets" {
  description = "Subnets configurations"
  type = map(object({
    address_prefix   = optional(string)
    address_prefixes = optional(list(string))
    name             = string
    nat_gateway = optional(object({
      id = string
    }))
    network_security_group = optional(object({
      id = string
    }))
    private_endpoint_network_policies             = optional(string, "Enabled")
    private_link_service_network_policies_enabled = optional(bool, true)
    route_table = optional(object({
      id = string
    }))
    service_endpoint_policies = optional(map(object({
      id = string
    })))
    service_endpoints               = optional(set(string))
    default_outbound_access_enabled = optional(bool, false)
    sharing_scope                   = optional(string, null)
    delegations = optional(list(object({
      name = string
      service_delegation = object({
        name = string
      })
    })))
  }))
  default = {}
}

variable "private_dns_zone_names" {
  description = "Linking Private DNS Zone names"
  type = list(object(
    {
      name                = string
      resource_group_name = string
    }
  ))
  default = []
}
