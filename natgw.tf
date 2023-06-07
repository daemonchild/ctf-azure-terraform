# NATGateway

resource "azurerm_nat_gateway" "natgw" {
  location            = var.location
  name                = "natGW-allsubnets"
  resource_group_name = local.resgrp
  depends_on = [
    azurerm_resource_group.resgrp,
  ]
}

resource "azurerm_public_ip" "pipnatgw" {
  allocation_method   = "Static"
  location            = var.location
  name                = "pip-natgw-allsubnets"
  resource_group_name = local.resgrp
  sku                 = "Standard"
  depends_on = [
    azurerm_resource_group.resgrp,
  ]
}

resource "azurerm_nat_gateway_public_ip_association" "natgwpipassc" {
  nat_gateway_id       = azurerm_nat_gateway.natgw.id
  public_ip_address_id = azurerm_public_ip.pipnatgw.id
  depends_on = [
    azurerm_nat_gateway.natgw,
    azurerm_public_ip.pipnatgw,
  ]
}

# Attach to subnets
/*
resource "azurerm_subnet_nat_gateway_association" "nsg-ass-subnet-guac" {
  nat_gateway_id = azurerm_nat_gateway.natgw.id
  subnet_id      = azurerm_subnet.subnetguac.id
  depends_on = [
    azurerm_nat_gateway.natgw,
    azurerm_subnet.subnetguac,
  ]
}

resource "azurerm_subnet_nat_gateway_association" "nsg-ass-subnet-cftd" {
  nat_gateway_id = azurerm_nat_gateway.natgw.id
  subnet_id      = azurerm_subnet.subnetctfd.id
  depends_on = [
    azurerm_nat_gateway.natgw,
    azurerm_subnet.subnetctfd,
  ]
}

resource "azurerm_subnet_nat_gateway_association" "nsg-ass-subnet-kali" {
  nat_gateway_id = azurerm_nat_gateway.natgw.id
  subnet_id      = azurerm_subnet.subnetkali.id
  depends_on = [
    azurerm_nat_gateway.natgw,
    azurerm_subnet.subnetkali,
  ]
}
*/