// _variables.agent.tf

variable "agent_pool_name" {
  description = "Name of the agent pool"
  type        = string
  default     = "self-hosted"
}

variable "use_self_hosted_agents" {
  description = "Use self-hosted agents"
  type        = bool
  default     = false
}
