// _variables.devbox.tf

variable "devbox_definitions_image_list" {
  description = "A list of VM Pool images for prepared DevBox Definitions."
  type = list(object({
    image_ref         = string
    hibernate_enabled = bool
  }))
  default = [
    {
      image_ref         = "galleries/default/images/microsoftwindowsdesktop_windows-ent-cpc_win11-24h2-ent-cpc"
      hibernate_enabled = true
    }
    // {
    //   image_ref         = "galleries/default/images/microsoftwindowsdesktop_windows-ent-cpc_win11-24h2-ent-cpc-m365",
    //   hibernate_enabled = true
    // },
    // {
    //   image_ref         = "galleries/default/images/microsoftvisualstudio_visualstudioplustools_vs-2022-pro-general-win10-m365-gen2",
    //   hibernate_enabled = true
    // },
  ]
}

variable "devbox_definitions_sku_list" {
  description = "A list of VM Pool SKUs for prepared DevBox Definitions."
  type        = list(string)
  default = [
    "general_i_8c32gb256ssd_v2",
    "general_i_8c32gb512ssd_v2",
    "general_i_8c32gb1024ssd_v2",
    "general_i_8c32gb2048ssd_v2",
    "general_i_16c64gb256ssd_v2",
    "general_i_16c64gb512ssd_v2",
    "general_i_16c64gb1024ssd_v2",
    "general_i_16c64gb2048ssd_v2",
    //"general_i_32c128gb256ssd_v2", // No SKU
    "general_i_32c128gb512ssd_v2",
    "general_i_32c128gb1024ssd_v2",
    "general_i_32c128gb2048ssd_v2",
  ]
}
