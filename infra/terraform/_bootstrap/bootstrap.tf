// bootstrap.tf

# Calculate the 'expiration_time' from 'expire_after' in the customer managed key policy
locals {
  # ignore year and month
  _hours           = local.duration.day * 24 + local.duration.hour
  _added_time      = "${local._hours}h${local.duration.minute}m${local.duration.second}s"
  _expiration_time = timeadd(timestamp(), local._added_time)

  _customer_managed_key_policy = (
    var.customer_managed_key_policy.rotation_policy.expire_after != null && var.customer_managed_key_policy.expiration_date == null
    ? merge(
      var.customer_managed_key_policy,
      { "expiration_date" : local._expiration_time },
    )
    : var.customer_managed_key_policy
  )
}

module "bootstrap" {
  # tflint-ignore: terraform_module_pinned_source
  source = "git::https://github.com/shigeyf/terraform-azurerm-bootstrap.git//infra/bootstrap?ref=main"

  resource_group_name  = local.resource_group_name
  storage_account_name = local.storage_account_name
  keyvault_name        = local.keyvault_name

  location                            = var.location
  tags                                = var.tags
  tfstate_container_name              = var.tfstate_container_name
  enable_user_assigned_identity       = var.enable_user_assigned_identity
  enable_storage_customer_managed_key = var.enable_storage_customer_managed_key
  storage_customer_managed_key_policy = local._customer_managed_key_policy
  bootstrap_config_filename           = var.bootstrap_config_filename
  tfbackend_config_template_filename  = var.tfbackend_config_template_filename
}
