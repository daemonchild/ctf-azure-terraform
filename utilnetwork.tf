

resource "azurerm_public_ip" "piputil" {
  allocation_method   = "Static"
  location            = var.location
  name                = "pip-utility"
  resource_group_name = local.resgrp
  sku                 = "Standard"
  depends_on = [
    azurerm_resource_group.resgrp,
  ]
}


resource "azurerm_linux_virtual_machine" "vm-utilserver" {
  admin_username        = var.adminuser
  location              = var.location
  name                  = "vm-UtilServer"
  network_interface_ids = [azurerm_network_interface.vm-utilserver-nic.id]
  resource_group_name   = local.resgrp
  size                  = var.utilitysku
  #admin_ssh_key {
  #  public_key = var.adminsshkey
  #  username   = var.adminuser
  #}
  admin_ssh_key {
    username   = var.adminuser
    public_key = tls_private_key.globalsshkey.public_key_openssh
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  source_image_reference {                # need to parse string with : delimiters
    offer     = "UbuntuServer"
    publisher = "Canonical"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  #user_data = "${base64encode(local.setup-vm-utilsvr)}"
  custom_data = filebase64("${path.module}/custom_data/vm-utilityserver.txt")
  depends_on = [
    azurerm_network_interface.vm-utilserver-nic,
    azurerm_public_ip.piputil,
    tls_private_key.globalsshkey
  ]
}

resource "azurerm_network_interface" "vm-utilserver-nic" {
  location            = "uksouth"
  name                = "vm-utilserver-nic"
  resource_group_name = local.resgrp
  ip_configuration {
    name                          = "ipconfigvm-utilserver"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.piputil.id
    subnet_id                     = azurerm_subnet.subnetutil.id
  }
  depends_on = [
    azurerm_public_ip.piputil,
    azurerm_subnet.subnetutil,
  ]
}



# Security Groups

resource "azurerm_network_security_group" "nsgsubnetutil" {     # may not need this
  location            = "uksouth"
  name                = "nsg-subnet-utility"
  resource_group_name = local.resgrp
  depends_on = [
    azurerm_resource_group.resgrp,
  ]
}
/*
resource "azurerm_network_interface_security_group_association" "nsgass-subnet-utilsvr" {
  network_interface_id      = azurerm_network_interface.vm-utilserver-nic.id
  network_security_group_id = azurerm_network_security_group.nsgsubnetutil.id
  depends_on = [
    azurerm_network_interface.vm-utilserver-nic,
    azurerm_network_security_group.nsgsubnetutil,
  ]
}
*/

resource "azurerm_network_security_group" "nsgvmutil" {
  location            = "uksouth"
  name                = "nsg-vm-utilserver"
  resource_group_name = local.resgrp
  depends_on = [
    azurerm_resource_group.resgrp,
  ]
}

resource "azurerm_network_interface_security_group_association" "nsgass-vm-utilsvr" {
  network_interface_id      = azurerm_network_interface.vm-utilserver-nic.id
  network_security_group_id = azurerm_network_security_group.nsgvmutil.id
  depends_on = [
    azurerm_network_interface.vm-utilserver-nic,
    azurerm_network_security_group.nsgvmutil,
  ]
}

resource "azurerm_network_security_rule" "nsgvmutil-22internet" {
  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "22"
  direction                   = "Inbound"
  name                        = "AllowSSHfromInternet"
  network_security_group_name = azurerm_network_security_group.nsgvmutil.name
  priority                    = 100
  protocol                    = "Tcp"
  resource_group_name         = local.resgrp
  source_address_prefix       = "Internet"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.nsgvmutil,
  ]
}

# For certbot testing

resource "azurerm_network_security_rule" "nsgvmutil-80internet" {
  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "80"
  direction                   = "Inbound"
  name                        = "AllowHTTPfromInternet"
  network_security_group_name = azurerm_network_security_group.nsgvmutil.name
  priority                    = 110
  protocol                    = "Tcp"
  resource_group_name         = local.resgrp
  source_address_prefix       = "Internet"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.nsgvmutil,
  ]
}

resource "azurerm_network_security_rule" "nsgvmutil-443internet" {
  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "443"
  direction                   = "Inbound"
  name                        = "AllowHTTPfromInternet"
  network_security_group_name = azurerm_network_security_group.nsgvmutil.name
  priority                    = 120
  protocol                    = "Tcp"
  resource_group_name         = local.resgrp
  source_address_prefix       = "Internet"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.nsgvmutil,
  ]
}

resource "azurerm_network_security_rule" "nsgvmutil-denyall" {
  access                      = "Deny"
  destination_address_prefix  = "*"
  destination_port_range      = "*"
  direction                   = "Inbound"
  name                        = "DenyAll"
  network_security_group_name = azurerm_network_security_group.nsgvmutil.name
  priority                    = 999
  protocol                    = "*"
  resource_group_name         = local.resgrp
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.nsgvmutil,
  ]
}
