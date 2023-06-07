
// Project: Terraform CTF Infrastructure in Azure
// Author:  Daemonchild
// Purpose: Build an environment for running Capture the Flag events

# Global Resources

resource "azurerm_resource_group" "resgrp" {
  name     = local.resgrp
  location = var.location
}

# Create (and display) an SSH key
resource "tls_private_key" "globalsshkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


# Required by KeyVault
data "azurerm_client_config" "current" {}

locals {
  msi_id          = null
  current_user_id = coalesce(local.msi_id, data.azurerm_client_config.current.object_id)
}

