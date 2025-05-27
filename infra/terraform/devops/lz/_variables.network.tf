// _variables.network.tf

variable "vnet_address_prefix" {
  description = "Address prefix for the virtual network"
  type        = string
}

variable "vnet_private_endpoint_subnet_name" {
  description = "Subnet name for the private endpoints in the virtual network"
  type        = string
}

variable "vnet_container_app_subnet_name" {
  description = "Subnet name for the Container Apps in the virtual network"
  type        = string
}

variable "vnet_container_instance_subnet_name" {
  description = "Subnet name for the Container Instances in the virtual network"
  type        = string
}

variable "vnet_subnets" {
  description = "Subnets configurations for the virtual network"
  type = map(object(
    {
      name                  = string    # Subnet name
      address_prefix        = string    # Subnet address prefix
      naming_prefix_enabled = bool      # Whether to add naming prefix ("snet") to the subnet name
      delegation = optional(set(object( # 'delegation' block
        {
          name = string
          service_delegation = object(
            {
              name    = string
              actions = optional(list(string))
            }
          )
        }
      )))
    }
  ))
  default = {}
}
