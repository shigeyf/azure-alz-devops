// iso8601_duration.tf

locals {
  regexp = "^P(?:(?P<year>[0-9]+)Y)?(?:(?P<month>[0-9]+)M)?(?:(?P<day>[0-9]+)D)?(?:[T](?:(?P<hour>[0-9]+)H)?(?:(?P<minute>[0-9]+)M)?(?:(?P<second>[0-9]+)S)?)?$"

  expiration = var.customer_managed_key_policy.rotation_policy.expire_after != null ? var.customer_managed_key_policy.rotation_policy.expire_after : "P"
  match      = regex(local.regexp, local.expiration)
  duration = {
    year   = local.match["year"] != null ? tonumber(local.match["year"]) : 0
    month  = local.match["month"] != null ? tonumber(local.match["month"]) : 0
    day    = local.match["day"] != null ? tonumber(local.match["day"]) : 0
    hour   = local.match["hour"] != null ? tonumber(local.match["hour"]) : 0
    minute = local.match["minute"] != null ? tonumber(local.match["minute"]) : 0
    second = local.match["second"] != null ? tonumber(local.match["second"]) : 0
  }
}
