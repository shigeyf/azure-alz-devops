// outputs.tf

output "output" {
  value = {
    acr_id           = azurerm_container_registry.this.id
    acr_login_server = azurerm_container_registry.this.login_server
    acr_uai_id       = var.enable_user_assigned_identity ? azurerm_user_assigned_identity.this[0].id : null
    acr_pe_id        = length(azurerm_private_endpoint.this) > 0 ? azurerm_private_endpoint.this[0].id : null,
  }
  description = "Ids for Container Registry resources"
}

output "ra_propagation_delay" {
  value       = time_sleep.wait_for_ra_propagation.id
  description = "Delay for role assignments propagation"
}
