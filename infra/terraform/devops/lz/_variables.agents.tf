// _variables.agents.tf

variable "agents_compute_type" {
  description = "Compute type for self-hosted agents (aca or aci)"
  type        = list(string)
  default     = []
}

variable "enable_agents_compute_zone_redundancy" {
  description = "Enable zone redundancy for self-hosted agents compute resources"
  type        = bool
  default     = false
}
