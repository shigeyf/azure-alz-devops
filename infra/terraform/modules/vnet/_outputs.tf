// _outputs.tf

output "output" {
  value = {
    vnet_name  = module.vnet.name
    vnet_id    = module.vnet.resource_id
    subnet_ids = { for key, subnet in module.vnet.subnets : key => subnet.resource_id }
    nsg_ids    = { for key, nsg in module.nsg : key => nsg.resource_id }
    nat_gw     = var.enable_nat_gateway ? module.natgw[0].resource_id : null
  }
  description = "Ids for Virtual Nwetwork resources"
}
