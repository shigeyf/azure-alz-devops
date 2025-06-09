// blob.container.role.tf

locals {
  _role_assignments = flatten([for id_key, id in azurerm_user_assigned_identity.this :
    [for c_key, container in azurerm_storage_container.this :
      {
        key          = "${c_key}-${id_key}"
        scope        = container.id
        principal_id = id.principal_id
      }
    ]
  ])
}

resource "azurerm_role_assignment" "this" {
  for_each             = { for ra in local._role_assignments : ra.key => ra }
  role_definition_name = "Storage Blob Data Contributor"
  scope                = each.value.scope
  principal_id         = each.value.principal_id

  depends_on = [
    azurerm_storage_container.this,
    azurerm_user_assigned_identity.this,
  ]
}


resource "azurerm_role_assignment" "delegator" {
  for_each             = azurerm_user_assigned_identity.this
  role_definition_name = "Storage Blob Delegator"
  scope                = local.bootstrap.storage_id
  principal_id         = each.value.principal_id

  depends_on = [
    azurerm_user_assigned_identity.this,
  ]
}
