// uami.federation.tf

resource "azurerm_federated_identity_credential" "this" {
  for_each            = module.github.federations
  name                = "${each.value.prefix}-${azurerm_user_assigned_identity.this[each.key].name}"
  resource_group_name = local.identity_resource_group_name
  parent_id           = azurerm_user_assigned_identity.this[each.key].id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = each.value.issuer
  subject             = each.value.subject
}
