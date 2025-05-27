// _output.tf

output "output" {
  value = {
    container_app_environment_id = azurerm_container_app_environment.this.id
  }
}
