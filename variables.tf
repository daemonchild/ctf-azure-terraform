
// Project: Terraform CTF Infrastructure in Azure
// Author:  Daemonchild
// Purpose: Build an environment for running Capture the Flag events

// variables.tf

variable "buildscripturl" {
  type        = string
  description = "Source for build scripts. See README for expected folder layout."
  sensitive = false
  nullable  = false
}

variable "project" {
  type        = string
  description = "Project name."
  validation {
    condition     = (length(var.project) <= 20 && length(var.project) > 2 && can(regex("[-\\w\\._\\(\\)]+", var.project)))
    error_message = "Project name may only contain alphanumeric characters, and underscores."
  }
  sensitive = false
  nullable  = false
}

variable "enviro" {
  type        = string
  description = "Status - live, dev."
  validation {
    condition     = (length(var.enviro) <= 5 && length(var.enviro) > 2 && can(regex("['live'|'dev']", var.enviro)))
    error_message = "Project environment can be 'live' or 'dev'."
  }
  sensitive = false
  nullable  = false
  default   = "dev"
}

variable "twooctetsinfra" {
  type        = string
  description = "IP subnet Infrastructure (first two octets only, eg 10.100)."
  sensitive   = false
  nullable    = false
}

variable "twooctetsctf" {
  type        = string
  description = "IP subnet for CTF Challenge Nets (first two octets only, eg 10.100)."
  sensitive   = false
  nullable    = false
}

variable "dnsdomain" {
  type        = string
  description = "DNS Domain Name."
  sensitive   = false
  nullable    = false
}

variable "ctfddnshostname" {
  type        = string
  description = "CTFd hostname."
  sensitive   = false
  nullable    = false
}

variable "guacdnshostname" {
  type        = string
  description = "Guacamole hostname."
  sensitive   = false
  nullable    = false
}

variable "location" {
  type        = string
  description = "Azure location for hosting his project."
  sensitive   = false
  nullable    = false
  default     = "uksouth"
}

variable "ctfdscale" {
  type        = number
  description = "Number of CTFd instances."
  sensitive   = false
  nullable    = false
}

variable "guacscale" {
  type        = number
  description = "Number of Guacamole instances."
  sensitive   = false
  nullable    = false
}

variable "kaliscale" {
  type        = number
  description = "Number of Kali Instances (teams)."
  sensitive   = false
  nullable    = false
}

variable "challengescale" {
  type        = number
  description = "Number of Challenge networks (teams)."
  sensitive   = false
  nullable    = false
}




# Mysql


variable "mysqlsku" {
  type        = string
  description = "SKU for Mysql"
  sensitive   = false
  nullable    = false
  default     = "B_Gen5_1"
}

# VMs

variable "utilitysku" {
  type        = string
  description = "SKU for Utility VM"
  sensitive   = false
  nullable    = false
  default     = "Standard_D2s_v3" # 2 CPU, 8GB RAM
}

variable "kalisku" {
  type        = string
  description = "SKU for Kali VM"
  sensitive   = false
  nullable    = false
  default     = "Standard_D2s_v3" # 2 CPU, 8GB RAM
}

variable "dockersku" {
  type        = string
  description = "SKU for Docker VM"
  sensitive   = false
  nullable    = false
  default     = "Standard_D2_v3"
}

variable "ctfdsku" {
  type        = string
  description = "SKU for CTFd VM"
  sensitive   = false
  nullable    = false
  default     = "Standard_D2_v3"
}

variable "guacdsku" {
  type        = string
  description = "SKU for Guacamole VM"
  sensitive   = false
  nullable    = false
  default     = "Standard_D2_v3"
}

variable "linuximage" {
  type        = string
  description = "Linux base image"
  sensitive   = false
  nullable    = false
  default     = "Canonical:UbuntuServer:18.04-LTS:latest"
}

variable "kaliimage" {
  type        = string
  description = "Kali base image"
  sensitive   = false
  nullable    = false
  default     = "kali-linux:kali:kali-20231:2023.1.0"
}


variable "adminuser" {
  type        = string
  description = "Global Admin Username"
  sensitive   = false
  nullable    = false
  default     = "ctfadmin"
}

#variable "adminsshkey" {
#
#  type        = string
#  description = "Global Admin SSH Key"
#  sensitive   = false
#  nullable    = false
#
#}

# The user shouldn't need to change anything below here

locals {
  resgrp = "rg-${lower(var.enviro)}-${lower(var.project)}"

  tags = {
    "project"     = "${var.project}",
    "environment" = "${var.enviro}"
  }


}

