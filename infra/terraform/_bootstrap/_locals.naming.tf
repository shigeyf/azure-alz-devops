// _locals.naming.tf

locals {
  rand_len = 4
}

// Generate a random string for the naming identifier
resource "random_string" "random" {
  length  = local.rand_len
  numeric = true
  lower   = true
  upper   = false
  special = false
}

// Load a module for Azure Region names and short names
module "azure_region" {
  source       = "claranet/regions/azurerm"
  version      = "8.0.1"
  azure_region = var.location
}

locals {
  rand_id             = random_string.random.result
  location_short_name = module.azure_region.location_short
}

// Load a module for Azure Resource naming
module "naming" {
  # tflint-ignore: terraform_module_pinned_source
  source         = "git::https://github.com/shigeyf/terraform-azurerm-naming?ref=master"
  suffix         = concat(var.naming_suffix, [local.location_short_name])
  suffix-padding = 5
}
