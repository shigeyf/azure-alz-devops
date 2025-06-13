// _variables.network.tf

variable "vnet_address_prefix" {
  description = "Address prefix for the virtual network"
  type        = string
}

variable "vnet_private_endpoint_subnet_address_prefix" {
  description = "Address prefix for the private endpoint subnet in the virtual network"
  type        = string
}

variable "vnet_gateway_subnet_address_prefix" {
  description = "Address prefix for the gateway subnet in the virtual network"
  type        = string
}

variable "vnet_container_app_subnet_address_prefix" {
  description = "Address prefix for the Container Apps subnet in the virtual network"
  type        = string
}

variable "vnet_container_instance_subnet_address_prefix" {
  description = "Address prefix for the Container Instances subnet in the virtual network"
  type        = string
}

variable "vnet_private_endpoint_subnet_name" {
  description = "Subnet name for the private endpoints in the virtual network"
  type        = string
  default     = "private-endpoints"
}

variable "vnet_container_app_subnet_name" {
  description = "Subnet name for the Container Apps in the virtual network"
  type        = string
  default     = "container-apps"
}

variable "vnet_container_instance_subnet_name" {
  description = "Subnet name for the Container Instances in the virtual network"
  type        = string
  default     = "container-instances"
}
