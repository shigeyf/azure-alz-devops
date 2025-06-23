// dev_center.box_def.tf

locals {
  _dev_box_defs = flatten([
    for index1, image in var.devbox_definitions_image_list : [
      for index2, sku in var.devbox_definitions_sku_list : {
        key          = "${index1}${format("%02d", index2 + 1)}"
        image_ref_id = image
        sku_name     = sku
      }
    ]
  ])
}

resource "azurerm_dev_center_dev_box_definition" "this" {
  for_each = local.enable_devbox ? { for def in local._dev_box_defs : def.key => def } : {}
  name     = "${local.devbox_def_name_prefix}${each.value.key}"
  location = var.location
  tags     = local.devbox_tags

  dev_center_id      = azurerm_dev_center.this[0].id
  image_reference_id = "${azurerm_dev_center.this[0].id}/${each.value.image_ref_id}"
  sku_name           = each.value.sku_name

  depends_on = [
    azurerm_resource_group.devbox,
    azurerm_dev_center.this,
  ]
}
