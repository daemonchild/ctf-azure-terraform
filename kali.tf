# Note: az vm image accept-terms --urn kali-linux:kali:kali-20231:2023.1.0

resource "azurerm_network_interface" "vm-kali-nic" {
  
  count = var.kaliscale

  location              = var.location
  name                  = "vm-kali-${count.index}-nic"

  resource_group_name   = local.resgrp
  ip_configuration {
    name                          = "vm-kali-${count.index}-ipconfig"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnetkali.id
  }
  depends_on = [
    azurerm_subnet.subnetkali,
  ]
}




resource "azurerm_linux_virtual_machine" "vm-kali" {

  count = var.kaliscale


  location              = var.location
  name                  = "vm-kali-${count.index}"
  network_interface_ids = [azurerm_network_interface.vm-kali-nic[count.index].id]
  resource_group_name   = local.resgrp
  size                  = var.kalisku
  admin_username = var.adminuser
  admin_ssh_key {
    username   = var.adminuser
    public_key = tls_private_key.globalsshkey.public_key_openssh
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  plan {
    name      = "kali-20231"
    product   = "kali"
    publisher = "kali-linux"
  }
  source_image_reference {
    offer     = "kali"
    publisher = "kali-linux"
    sku       = "kali-20231"
    version   = "2023.1.0"
  }
  depends_on = [
    azurerm_network_interface.vm-kali-nic,
  ]
}