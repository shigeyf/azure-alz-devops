// _variables.container_instance.tf

variable "container_instance_name" {
  description = "Container Instance name"
  type        = string
}

variable "container_instance_count" {
  description = "Count of Container Instance"
  type        = number
  default     = 1
}

variable "container_instance_sku" {
  description = "Container Instance SKU"
  type        = string
  default     = "Standard"
}

variable "container_instance_enable_private_network" {
  description = "Enable private network for the Container Instances"
  type        = bool
  default     = false
}

variable "container_instance_subnet_id" {
  description = "Subnet Id for the Container Instances"
  type        = string
  default     = ""
}

variable "container_instance_availability_zones" {
  description = "List of availability zones for the Container Instances"
  type        = list(string)
  default     = null
}

variable "container_instance_spec" {
  description = "Parameters for the Container Instances"
  type = object({
    os_type = string
    container = object({
      name                         = string
      image_name                   = string
      cpu                          = number
      memory                       = number
      cpu_limit                    = optional(number, 1)
      memory_limit                 = optional(number, 2)
      environment_variables        = optional(list(object({ name = string, value = string })), [])
      secure_environment_variables = optional(list(object({ name = string, value = string })), [])
      ports = optional(list(object({
        port     = number
        protocol = string
      })), [])
    })
  })
}
