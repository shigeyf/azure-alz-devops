// resource_provider_registration.tf

locals {
  _required_resource_providers = concat(
    var.required_resource_providers,
    var.enable_extended_resource_providers ? var.extended_required_resource_providers : [],
    var.enable_all_resource_providers ? var.all_resource_providers : [],
  )
}

resource "azurerm_resource_provider_registration" "this" {
  for_each = toset(local._required_resource_providers)
  name     = each.key
}
