// _variables.environment.tf

variable "container_app_environment_name" {
  type        = string
  description = "Name of the Container App Environment"
}

variable "workload_profile_name" {
  type        = string
  description = "Name of the workload profile for the Container App Environment"
}

variable "workload_profile_type" {
  type        = string
  description = "Workload profile type for the workloads to run on the Container App Environment"
  default     = "Consumption"
  # Possible values include Consumption, D4, D8, D16, D32, E4, E8, E16 and E32.

  validation {
    condition = (
      var.workload_profile_type == "Consumption"
      || var.workload_profile_type == "D4"
      || var.workload_profile_type == "D8"
      || var.workload_profile_type == "D16"
      || var.workload_profile_type == "D32"
      || var.workload_profile_type == "E4"
      || var.workload_profile_type == "E8"
      || var.workload_profile_type == "E16"
      || var.workload_profile_type == "E32"
    )
    error_message = "workload_profile_type must be either Consumption, D4, D8, D16, D32, E4, E8, E16 and E32"
  }
}

variable "workload_maximum_count" {
  type        = number
  description = "Maximum number of instances of workload profile that can be deployed in the Container App Environment"
  default     = 0
}

variable "workload_minimum_count" {
  type        = number
  description = "Minimum number of instances of workload profile that can be deployed in the Container App Environment"
  default     = 0
}

variable "logs_destination" {
  type        = string
  description = "Log destination for the Container App Environment, can be 'azure-monitor' or 'log-analytics'"
  default     = "azure-monitor"

  validation {
    condition     = var.logs_destination == "azure-monitor" || var.logs_destination == "log-analytics"
    error_message = "logs_destination must be either 'azure-monitor' or 'log-analytics'"
  }
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace Id for the case when log_destination is defined with 'log-analytics'"
  default     = null
  # required if logs_destination is set to log-analytics.
  # Cannot be set if logs_destination is set to azure-monitor.

  validation {
    condition     = (var.logs_destination == "azure-monitor" && var.log_analytics_workspace_id == null) || (var.logs_destination == "log-analytics" && var.log_analytics_workspace_id != null)
    error_message = "log_analytics_workspace_id must be set when logs_destination is 'log-analytics' and must not be set when logs_destination is 'azure-monitor'"
  }
}

variable "container_app_subnet_id" {
  type        = string
  description = "Container App Subnet Id (The Subnet must have a /27 or larger address space)"
  default     = null
}

variable "internal_load_balancer_enabled" {
  type        = bool
  description = "Enable Internal Load Balancer for the Container App Environment"
  default     = false

  validation {
    condition     = var.container_app_subnet_id != null || (var.container_app_subnet_id == null && var.internal_load_balancer_enabled == false)
    error_message = "internal_load_balancer_enabled can be set to true only if container_app_subnet_id is specified"
  }
}

variable "zone_redundancy_enabled" {
  type        = bool
  description = "Enable Zone Redundancy for the Container App Environment"
  default     = false

  validation {
    condition     = var.container_app_subnet_id != null || (var.container_app_subnet_id == null && var.zone_redundancy_enabled == false)
    error_message = "zone_redundancy_enabled can be set to true only if container_app_subnet_id is specified"
  }
}

variable "container_app_infra_resource_group_name" {
  type        = string
  description = "Name of the resource group where the infrastructure resources are created"
  default     = null
  # Only valid if a workload_profile is specified.
  # If infrastructure_subnet_id is specified, this resource group will be created
  # in the same subscription as container_app_subnet_id (infrastructure_subnet_id).
}
