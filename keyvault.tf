
locals {

  keyvaultname = "keyvault-${var.project}"

}


resource "azurerm_key_vault" "vault" {
  name                       = local.keyvaultname
  location                   = var.location
  resource_group_name        = local.resgrp
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 14

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = local.current_user_id

    key_permissions    = local.key_permissions
    secret_permissions = local.secret_permissions
  }
}


locals {

  key_permissions    = ["List", "Create", "Delete", "Get", "Purge", "Recover", "Update", "GetRotationPolicy", "SetRotationPolicy"]
  secret_permissions = ["Set","List", "Delete", "Get"]

}
