// _variables.devbox.tf

variable "devbox_maximum_dev_boxes_per_user" {
  description = "When specified, limits the maximum number of Dev Boxes a single user can create across all pools in the project."
  type        = number
  default     = 2
}

variable "devbox_local_administrator_enabled" {
  description = "Specifies whether owners of Dev Boxes in the Dev Center Project Pool are added as local administrators on the Dev Box."
  type        = bool
  default     = true
}

variable "devbox_stop_on_disconnect_grace_period_minutes" {
  description = "The specified time in minutes to wait before stopping a Dev Center Dev Box once disconnect is detected. Possible values are between 60 and 480."
  type        = number
  default     = 60
}

#variable "devops_stop_on_no_connect_grace_period_minutes" {
#  description = "The specified time in minutes to wait before stopping a Dev Center Dev Box once no connection is detected. Possible values are between 60 and 480."
#  type        = number
#  default     = 60
#}
