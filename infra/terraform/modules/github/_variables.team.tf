// _variables.team.tf

variable "teams" {
  description = "GitHub Teams to be created"
  type = map(object({
    description = string
    permission  = string
  }))
  default = {}
}
