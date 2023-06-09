locals {

  mysqlsvrname = "mysql-${var.project}"
  #mysqlsvrurl  = "${local.mysqlsvrname}.mysql.database.azure.com"
  mysqladmin = var.adminuser

  guacmysqluser = "guacdbuser"
  ctfdmysqluser = "ctfddbuser"
  guacdbname    = "guacamoledb"
  ctfddbname    = "ctfd"

}

# Generate random value for the login passwords
resource "random_password" "mysqladminpwd" {
  length           = 32
  lower            = true
  min_lower        = 4
  min_numeric      = 4
  min_special      = 4
  min_upper        = 4
  numeric          = true
  override_special = "_"
  special          = true
  upper            = true
}

# Generate random value for the login passwords
resource "random_password" "mysqlctfdpwd" {
  length           = 32
  lower            = true
  min_lower        = 4
  min_numeric      = 4
  min_special      = 4
  min_upper        = 4
  numeric          = true
  override_special = "_"
  special          = true
  upper            = true
}

# Generate random value for the login passwords
resource "random_password" "mysqlquacpwd" {
  length           = 32
  lower            = true
  min_lower        = 4
  min_numeric      = 4
  min_special      = 4
  min_upper        = 4
  numeric          = true
  override_special = "_"
  special          = true
  upper            = true
}

/*
resource "azurerm_key_vault_secret" "mysqladminpwd" {
  name         = "mysqladminpwd"
  value        = random_password.mysqladminpwd.result
  key_vault_id = azurerm_key_vault.vault.id

  depends_on = [
    azurerm_resource_group.resgrp,
    azurerm_key_vault.vault,
  ]
}

resource "azurerm_key_vault_secret" "mysqlctfdpwd" {
  name         = "mysqlctfdpwd"
  value        = random_password.mysqlctfdpwd.result
  key_vault_id = azurerm_key_vault.vault.id

  depends_on = [
    azurerm_resource_group.resgrp,
    azurerm_key_vault.vault,
  ]
}

resource "azurerm_key_vault_secret" "mysqlquacpwd" {
  name         = "mysqlquacpwd"
  value        = random_password.mysqlquacpwd.result
  key_vault_id = azurerm_key_vault.vault.id

  depends_on = [
    azurerm_resource_group.resgrp,
    azurerm_key_vault.vault,
  ]
}
*/

resource "azurerm_mysql_server" "mysqlserver" {
  location                         = var.location
  name                             = local.mysqlsvrname
  resource_group_name              = local.resgrp
  sku_name                         = var.mysqlsku
  ssl_enforcement_enabled          = false
  ssl_minimal_tls_version_enforced = "TLSEnforcementDisabled"
  version                          = "5.7"
  administrator_login              = local.mysqladmin
  administrator_login_password     = random_password.mysqladminpwd.result

  depends_on = [
    azurerm_resource_group.resgrp,
    azurerm_key_vault.vault,
  ]
}


resource "azurerm_mysql_firewall_rule" "mysql-fw-utilserver-pip" {
  end_ip_address      = "255.255.255.255"
  name                = "AllowUtilServer"
  resource_group_name = local.resgrp
  server_name         = local.mysqlsvrname
  start_ip_address    = "${azurerm_public_ip.piputil.ip_address}"
  depends_on = [
    azurerm_public_ip.piputil,
  ]
}


/*
resource "azurerm_mysql_firewall_rule" "mysql-fw-appgw-pip" {
  end_ip_address      = "255.255.255.255"
  name                = "AllowAppGW"
  resource_group_name = local.resgrp
  server_name         = local.mysqlsvrname
  start_ip_address    = "${azurerm_public_ip.appgwpip.ip_address}"
  depends_on = [
    azurerm_public_ip.appgwpip,
  ]
}
*/


# Databases

resource "azurerm_mysql_database" "db-ctfd" {
  name                = "ctfd"
  resource_group_name = local.resgrp
  server_name         = azurerm_mysql_server.mysqlserver.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_mysql_database" "db-guacamoledb" {
  name                = "guacamoledb"
  resource_group_name = local.resgrp
  server_name         = azurerm_mysql_server.mysqlserver.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}