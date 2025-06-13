// _variables.agents.tf

variable "enable_agents_environment_zone_redundancy" {
  description = "Enable zone redundancy for self-hosted agents environment. This is only applicable if agents are deployed on a Container App Environment."
  type        = bool
  default     = true
}
