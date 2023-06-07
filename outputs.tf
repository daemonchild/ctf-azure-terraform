

output "resource_group_name" {
  value = azurerm_resource_group.resgrp.name
}

output "azurerm_key_vault_name" {
  value = azurerm_key_vault.vault.name
}

output "azurerm_key_vault_id" {
  value = azurerm_key_vault.vault.id
}

output "mysql_server_fqdn" {
  value = azurerm_mysql_server.mysqlserver.fqdn
}

output "mysql_server_adminuser" {
  value = "${local.mysqladmin}@${local.mysqlsvrname}"
}

output "mysql_server_adminpassword" {
  value = "${random_password.mysqladminpwd.result}"
  sensitive = true
}

output "nat_gw_public_ip"{
  value = azurerm_public_ip.pipnatgw.ip_address
}

output "utilserver_public_ip" {
  value = azurerm_public_ip.piputil.ip_address
}

output "utilserver_private_ip" {
  value = azurerm_network_interface.vm-utilserver-nic.ip_configuration[0].private_ip_address
}

output "admin_username" {
  value     = var.adminuser
  sensitive = true
}

output "admin_ssh_private_key" {
  value     = tls_private_key.globalsshkey.private_key_pem
  sensitive = true
}