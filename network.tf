# Networking

locals {

  ipsubnetinfra = "${var.twooctetsinfra}.0.0/16"
  utilsubnet    = "${var.twooctetsinfra}.250.0/24"
  #mysqlsubnet   = "${var.twooctetsinfra}.1.0/24"     # adjust numbering below
  guacsubnet    = "${var.twooctetsinfra}.2.0/24"
  ctfdsubnet    = "${var.twooctetsinfra}.3.0/24"
  appgwsubnet   = "${var.twooctetsinfra}.4.0/24"

  ipsubnetctf     = "${var.twooctetsctf}.0.0/16"
  kalisubnet      = "${var.twooctetsctf}.0.0/22" # 1024 IP addresses
  challengesubnet = "${var.twooctetsctf}.254.0/24"

  vnetinfraname = "vnet-infra-${var.project}"
  vnetctfname   = "vnet-ctf-${var.project}"

  utilsubnetname  = "subnet-utility"
  guacsubnetname  = "subnet-guacamole"
  ctfdsubnetname  = "subnet-ctfd"
  appgwsubnetname = "subnet-appgw"

  challengesubnetname = "subnet-challenge"
  kalisubnetname      = "subnet-kali"

}

resource "azurerm_virtual_network" "vnetinfra" {
  address_space       = [local.ipsubnetinfra]
  location            = var.location
  name                = local.vnetinfraname
  resource_group_name = local.resgrp
  depends_on = [
    azurerm_resource_group.resgrp,
  ]
}

resource "azurerm_virtual_network" "vnetctf" {
  address_space       = [local.ipsubnetctf]
  location            = var.location
  name                = local.vnetctfname
  resource_group_name = local.resgrp
  depends_on = [
    azurerm_resource_group.resgrp,
  ]
}

resource "azurerm_subnet" "subnetutil" {
  address_prefixes     = [local.utilsubnet]
  name                 = local.utilsubnetname
  resource_group_name  = local.resgrp
  virtual_network_name = local.vnetinfraname
  depends_on = [
    azurerm_virtual_network.vnetinfra,
  ]
}

resource "azurerm_subnet" "subnetappgw" {
  address_prefixes     = [local.appgwsubnet]
  name                 = local.appgwsubnetname
  resource_group_name  = local.resgrp
  virtual_network_name = local.vnetinfraname
  depends_on = [
    azurerm_virtual_network.vnetinfra,
  ]
}

resource "azurerm_subnet" "subnetctfd" {
  address_prefixes     = [local.ctfdsubnet]
  name                 = local.ctfdsubnetname
  resource_group_name  = local.resgrp
  virtual_network_name = local.vnetinfraname
  depends_on = [
    azurerm_virtual_network.vnetinfra,
  ]
}

resource "azurerm_subnet" "subnetguac" {
  address_prefixes     = [local.guacsubnet]
  name                 = local.guacsubnetname
  resource_group_name  = local.resgrp
  virtual_network_name = local.vnetinfraname
  depends_on = [
    azurerm_virtual_network.vnetinfra,
  ]
}

resource "azurerm_subnet" "subnetkali" {
  address_prefixes     = [local.kalisubnet]
  name                 = local.kalisubnetname
  resource_group_name  = local.resgrp
  virtual_network_name = local.vnetctfname
  depends_on = [
    azurerm_virtual_network.vnetctf,
  ]
}

resource "azurerm_subnet" "subnetchallenge" {
  address_prefixes     = [local.challengesubnet]
  name                 = local.challengesubnetname
  resource_group_name  = local.resgrp
  virtual_network_name = local.vnetctfname
  depends_on = [
    azurerm_virtual_network.vnetctf,
  ]
}

