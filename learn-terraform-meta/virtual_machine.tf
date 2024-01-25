resource "azurerm_resource_group" "examplevm" {
  name     = "examplevm-resources"
  location = "eastus2"
}

resource "azurerm_virtual_network" "examplevm" {
  name                = "examplevm-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.examplevm.location
  resource_group_name = azurerm_resource_group.examplevm.name
}

resource "azurerm_subnet" "examplevm" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.examplevm.name
  virtual_network_name = azurerm_virtual_network.examplevm.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "examplevm" {
  # Crea 3 interfaces
  for_each = toset(["alfa", "beta", "gamma"])

  name                = "nic-${each.value}"
  location            = azurerm_resource_group.examplevm.location
  resource_group_name = azurerm_resource_group.examplevm.name


  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.examplevm.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "examplevm" {
  # ignora cambios en el atributo admin_password
  lifecycle {
    ignore_changes = [admin_password]
  }

  for_each = azurerm_network_interface.examplevm

  name                = replace(each.value.name, "nic-", "vm-")
  resource_group_name = azurerm_resource_group.examplevm.name
  location            = azurerm_resource_group.examplevm.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    each.value.id
  ]

  admin_password                  = var.admin_password
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}