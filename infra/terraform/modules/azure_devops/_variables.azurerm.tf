// _variables.azurerm.tf

variable "azurerm_spn_tenantid" {
  description = "Tenant Id of the Azure target"
  type        = string
}

variable "azurerm_subscription_id" {
  description = "Subscription Id of the Azure target"
  type        = string
}

variable "azurerm_subscription_name" {
  description = "Subscription Name of the Azure target"
  type        = string
}
