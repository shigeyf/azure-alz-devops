// resource_provider.tf

locals {
  _required_resource_providers = [
    "Microsoft.App",
    "Microsoft.OperationalInsights",
  ]
}

resource "azurerm_resource_provider_registration" "this" {
  for_each = toset(local._required_resource_providers)
  name     = each.value
}
