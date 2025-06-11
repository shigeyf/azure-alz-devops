// _variables.agent.tf

#variable "use_self_hosted_runners" {
#  description = "Use self-hosted runners"
#  type        = bool
#  default     = false
#}

variable "runner_group_name" {
  description = "Name of the GitHub Runner Group"
  type        = string
  default     = ""
}
