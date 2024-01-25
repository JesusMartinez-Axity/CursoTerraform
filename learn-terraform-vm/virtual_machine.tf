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
  name                = "examplevm-nic"
  location            = azurerm_resource_group.examplevm.location
  resource_group_name = azurerm_resource_group.examplevm.name


  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.examplevm.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "examplevm" {
  name                = "examplevm-machine"
  resource_group_name = azurerm_resource_group.examplevm.name
  location            = azurerm_resource_group.examplevm.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.examplevm.id
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