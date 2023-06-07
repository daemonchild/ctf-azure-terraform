

// versions.tf

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">2.51.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "~>4.0"
    }
  }
}

provider "azurerm" {

  features {}
}

