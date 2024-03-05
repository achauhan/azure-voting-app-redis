# Define provider (Azure)
provider "azurerm" {
  features {}
}

# Create resource group
resource "azurerm_resource_group" "myresourcegroup" {
  name     = "myresourcegroup"
  location = "East US"
}

# Create storage account
resource "azurerm_storage_account" "mystorageaccount" {
  name                     = "mystorageaccount"
  resource_group_name      = azurerm_resource_group.myresourcegroup.name
  location                 = azurerm_resource_group.myresourcegroup.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create virtual network
resource "azurerm_virtual_network" "myvnet" {
  name                = "myvnet"
  resource_group_name = azurerm_resource_group.myresourcegroup.name
  location            = azurerm_resource_group.myresourcegroup.location
  address_space       = ["10.0.0.0/16"]
}

# Create virtual machine
resource "azurerm_virtual_machine" "myvm" {
  name                  = "myvm"
  resource_group_name   = azurerm_resource_group.myresourcegroup.name
  location              = azurerm_resource_group.myresourcegroup.location
  network_interface_ids = [azurerm_network_interface.myvmNic.id]

  vm_size = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "myvm"
    admin_username = "myadmin"
    admin_password = "mypassword"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

# Create network interface
resource "azurerm_network_interface" "myvmNic" {
  name                = "myvmNic"
  resource_group_name = azurerm_resource_group.myresourcegroup.name
  location            = azurerm_resource_group.myresourcegroup.location

  ip_configuration {
    name                          = "myvmNicConfig"
    subnet_id                     = azurerm_virtual_network.myvnet.subnet[0].id
  }
}
