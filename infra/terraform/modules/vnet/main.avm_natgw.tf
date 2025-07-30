// main.avm_natgw.tf

module "natgw" {
  count   = var.enable_nat_gateway ? 1 : 0
  source  = "Azure/avm-res-network-natgateway/azurerm"
  version = "0.2.1"

  name                = var.nat_gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  public_ips = {
    public_ip_1 = {
      name = var.nat_gateway_public_ip_name
    }
  }
}
