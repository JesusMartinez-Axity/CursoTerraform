output "resource_group_id" {
  value = azurerm_resource_group.rg.id
  description = "Resource group Id"
}

output "address" {
  value = azurerm_virtual_network.vnet.address_space
  sensitive = true
}