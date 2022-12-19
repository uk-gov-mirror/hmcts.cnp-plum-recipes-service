data "azurerm_client_config" "current" {
}

resource "azurerm_resource_group" "expAfter_testing_rg" {
  name     = "expAfter-testing-${var.env}"
  location = "UK South"
  tags     = var.common_tags
}

resource "azurerm_key_vault" "expAfter_testing_kv" {
  name                = "xptst-${var.env}"
  location            = azurerm_resource_group.expAfter_testing_rg.location
  resource_group_name = azurerm_resource_group.expAfter_testing_rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  soft_delete_retention_days  = 7
  tags                = var.common_tags
}

resource "azurerm_storage_account" "expAfter_testing_sa" {
  name                     = "xptst${var.env}"
  resource_group_name      = azurerm_resource_group.expAfter_testing_rg.name
  location                 = azurerm_resource_group.expAfter_testing_rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags                     = var.common_tags
}

resource "azurerm_virtual_network" "expAfter_testing_vnet" {
  name                = "xptst-vnet"
  location            = azurerm_resource_group.expAfter_testing_rg.location
  resource_group_name = azurerm_resource_group.expAfter_testing_rg.name
  address_space       = ["10.0.0.0/16"]
  tags                = var.common_tags
}

resource "azurerm_subnet" "expAfter_testing_front_subnet" {
  name                 = "xptst-front-0-${var.env}"
  resource_group_name  = azurerm_resource_group.expAfter_testing_rg.name
  virtual_network_name = azurerm_virtual_network.expAfter_testing_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "expAfter_testing_back_subnet" {
  name                 = "xptst-back-0-${var.env}"
  resource_group_name  = azurerm_resource_group.expAfter_testing_rg.name
  virtual_network_name = azurerm_virtual_network.expAfter_testing_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_postgresql_server" "test_psqlserver" {
  name                = "xptst-psqlserver"
  location            = azurerm_resource_group.expAfter_testing_rg.location
  resource_group_name = azurerm_resource_group.expAfter_testing_rg.name

  administrator_login          = "psqladmin"
  administrator_login_password = "3l3Ph4nt5rC0oL!@@"


  sku_name                         = "GP_Gen5_4"
  version                          = "11"
  public_network_access_enabled    = false
  ssl_minimal_tls_version_enforced = "TLSEnforcementDisabled"
  ssl_enforcement_enabled          = false
  tags                             = var.common_tags
}


# app gateway stuff
resource "azurerm_public_ip" "expAfter_testing_pip" {
  name                = "xptst-pip"
  resource_group_name = azurerm_resource_group.expAfter_testing_rg.name
  location            = azurerm_resource_group.expAfter_testing_rg.location
  allocation_method   = "Dynamic"
  tags                = var.common_tags 
}

locals {
  backend_address_pool_name      = "${azurerm_virtual_network.expAfter_testing_vnet.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.expAfter_testing_vnet.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.expAfter_testing_vnet.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.expAfter_testing_vnet.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.expAfter_testing_vnet.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.expAfter_testing_vnet.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.expAfter_testing_vnet.name}-rdrcfg"
}

resource "azurerm_application_gateway" "expAfter_testing_appgw" {
  name                = "xptst-appgateway"
  resource_group_name = azurerm_resource_group.expAfter_testing_rg.name
  location            = azurerm_resource_group.expAfter_testing_rg.location
  tags                = var.common_tags

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "xptst-gateway-ip-configuration"
    subnet_id = azurerm_subnet.expAfter_testing_front_subnet.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.expAfter_testing_pip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}

resource "azurerm_api_management" "expAfter_testing_apimgmt" {
  name                = "xptst-apimgmt"
  location            = azurerm_resource_group.expAfter_testing_rg.location
  resource_group_name = azurerm_resource_group.expAfter_testing_rg.name
  publisher_name      = "Boris Johnson"
  publisher_email     = "dummyemail@hmcts.net"

  sku_name = "Developer_1"
  tags     = var.common_tags
}

resource "azurerm_route_table" "expAfter_testing_rt" {
  name                          = "xptst-route-table"
  location                      = azurerm_resource_group.expAfter_testing_rg.location
  resource_group_name           = azurerm_resource_group.expAfter_testing_rg.name
  disable_bgp_route_propagation = false

  route {
    name           = "route1"
    address_prefix = "10.1.0.0/16"
    next_hop_type  = "VnetLocal"
  }

  tags = var.common_tags
}

resource "azurerm_network_security_group" "expAfter_testing_nsg" {
  name                = "xptst-dummy-nsg"
  location            = azurerm_resource_group.expAfter_testing_rg.location
  resource_group_name = azurerm_resource_group.expAfter_testing_rg.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.common_tags
}

