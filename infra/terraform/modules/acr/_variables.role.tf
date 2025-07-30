// _variables.role.tf

variable "ra_propagation_time" {
  type        = string
  description = "Wait seconds to propagate role assignments"
  default     = "60s"
}

variable "role_assignments" {
  type = list(object({
    principal_id         = string
    role_definition_name = string
  }))
  description = "Role assignments"
  default     = []
}
