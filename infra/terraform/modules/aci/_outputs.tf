// _outputs.tf

output "output" {
  value = {
    container_instances = { for i in azurerm_container_group.this : i.name => i.id }
  }
  description = "Container Instance resources"
}
