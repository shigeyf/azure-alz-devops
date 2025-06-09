// blob.container.tf

locals {
  contaners = {
    "tfstate" = {
      name               = "${var.project_name}-tfstate"
      storage_account_id = local.bootstrap.storage_id
    },
    "log" = {
      name               = "${var.project_name}-log"
      storage_account_id = local.bootstrap.storage_id
    }
  }
}

resource "azurerm_storage_container" "this" {
  for_each              = local.contaners
  name                  = each.value.name
  storage_account_id    = each.value.storage_account_id
  container_access_type = "private"
}
