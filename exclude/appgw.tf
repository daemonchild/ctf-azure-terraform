// App Gateway

locals {

  appgwname         = "appgw-${var.project}"
  appgwpipname      = "pip-${local.appgwname}"
  appgwfrontendname = "frontend-${local.appgwname}"

  # CTFd

  ctfdfqdn            = "${var.ctfddnshostname}.${var.dnsdomain}"
  ctfdbackendpoolname = "${var.project}-pool-ctfd"
  ctfdbackendsettings = "${var.project}-backend-ctfd"
  ctfdlistenername    = "${var.project}-listener-ctfd"
  ctfdroutingrule     = "${var.project}-routingrule-ctfd"

  # Guacamole

  guacdfqdn           = "${var.guacdnshostname}.${var.dnsdomain}"
  guacbackendpoolname = "${var.project}-pool-guac"
  guacbackendsettings = "${var.project}-backend-guac"
  guaclistenername    = "${var.project}-listener-guac"
  guacroutingrule     = "${var.project}-routingrule-guac"


}

resource "azurerm_application_gateway" "appgw" {
  name                = local.appgwname
  location            = var.location
  resource_group_name = local.resgrp
  backend_address_pool {
    name = local.ctfdbackendpoolname
  }
  backend_address_pool {
    name = local.guacbackendpoolname
  }
  backend_http_settings {
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    cookie_based_affinity = "Enabled"
    name                  = local.ctfdbackendsettings
    port                  = 80
    probe_name            = "heathprobe-ctfd"
    protocol              = "Http"
    request_timeout       = 30
  }
  backend_http_settings {
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    cookie_based_affinity = "Enabled"
    name                  = local.guacbackendsettings
    path                  = "/"
    port                  = 80
    probe_name            = "heathprobe-guac"
    protocol              = "Http"
    request_timeout       = 30
  }
  frontend_ip_configuration {
    name                 = local.appgwfrontendname
    public_ip_address_id = azurerm_public_ip.pipappgw.id
  }
  frontend_port {
    name = "port_443"
    port = 443
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = azurerm_subnet.subnetappgw.id
  }
  http_listener {
    frontend_ip_configuration_name = local.appgwfrontendname
    frontend_port_name             = "port_443"
    host_name                      = local.ctfdfqdn
    name                           = local.ctfdlistenername
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "certguacamole"
    custom_error_configuration {
      custom_error_page_url = "https://h4ck3r.uk" # MODIFY!
      status_code           = "HttpStatus403"
    }
    custom_error_configuration {
      custom_error_page_url = "https://h4ck3r.uk" # MODIFY!
      status_code           = "HttpStatus502"
    }
  }
  http_listener {
    frontend_ip_configuration_name = local.appgwfrontendname
    frontend_port_name             = "port_443"
    host_name                      = local.guacdfqdn
    name                           = local.guaclistenername
    protocol                       = "Https"
    require_sni                    = true
    ssl_certificate_name           = "certctfd"
    custom_error_configuration {
      custom_error_page_url = "https://h4ck3r.uk" # MODIFY!
      status_code           = "HttpStatus403"
    }
    custom_error_configuration {
      custom_error_page_url = "https://h4ck3r.uk" # MODIFY!
      status_code           = "HttpStatus502"
    }
  }

  probe {
    host                = local.ctfdfqdn
    interval            = 30
    name                = "healthprobe-ctfd"
    path                = "/"
    port                = 80
    protocol            = "Http"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }
  probe {
    host                = local.guacdfqdn
    interval            = 30
    name                = "heathprobe-guac"
    path                = "/guacamole/images/logo-64.png"
    protocol            = "Http"
    timeout             = 30
    unhealthy_threshold = 3
    match {
      status_code = ["200-399"]
    }
  }

  request_routing_rule {
    backend_address_pool_name  = local.ctfdbackendpoolname
    backend_http_settings_name = local.ctfdbackendsettings
    http_listener_name         = local.ctfdlistenername
    name                       = local.ctfdroutingrule
    priority                   = 100
    rule_type                  = "Basic"
  }
  request_routing_rule {
    backend_address_pool_name  = local.guacbackendpoolname
    backend_http_settings_name = local.guacbackendsettings
    http_listener_name         = local.guaclistenername
    name                       = local.guacroutingrule
    priority                   = 110
    rule_type                  = "Basic"
  }
  sku {
    capacity = 3
    name     = "Standard_v2"
    tier     = "Standard_v2"
  }
  ssl_certificate {
    name = "certctfd"             # expanding `ssl_certificate`: 
                                  # either `key_vault_secret_id` or `data` must be specified for the `ssl_certificate` block "certctfd"
  }
  ssl_certificate {
    name = "certguacamole"
  }

  depends_on = [
    azurerm_public_ip.pipappgw,
    azurerm_subnet.subnetappgw,
  ]
}





resource "azurerm_public_ip" "pipappgw" {
  allocation_method   = "Static"
  location            = var.location
  name                = "pip-appgw"
  resource_group_name = local.resgrp
  sku                 = "Standard"
  depends_on = [
    azurerm_resource_group.resgrp,
  ]
}