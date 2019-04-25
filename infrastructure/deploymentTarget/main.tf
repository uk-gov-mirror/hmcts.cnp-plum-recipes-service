

provider "azurerm" {
  
  version = "=1.19.0"
}

locals {
  # list of the thumbprints of the SSL certificates that should be accepted by the API (gateway)
  allowed_certificate_thumbprints = [
    # API tests
    "${var.api_gateway_test_certificate_thumbprint}"
  ]
  thumbprints_in_quotes = "${formatlist("&quot;%s&quot;", local.allowed_certificate_thumbprints)}"
  thumbprints_in_quotes_str = "${join(",", local.thumbprints_in_quotes)}"
  api_policy = "${replace(file("template/api-policy.xml"), "ALLOWED_CERTIFICATE_THUMBPRINTS", local.thumbprints_in_quotes_str)}"
  //api_base_path = "rhubarb-recipes-api"
  app = "recipe-backend"

  shared_infra_rg = "${var.product}-shared-infrastructure-${var.env}"
  vault_name = "${var.product}si-${var.env}"
  domain_name = "${var.env}.platform.hmcts.net"
}

module "recipe-backend" {
  source       = "git@github.com:hmcts/cnp-module-webapp?ref=master"
  product      = "${var.product}-${local.app}"
  location     = "${var.location}"
  env          = "${var.env}"
  deployment_target = "${var.deployment_target}"
  ilbIp        = "${var.ilbIp}"
  subscription = "${var.subscription}"
  is_frontend  = false
  capacity     = "${var.capacity}"
  common_tags  = "${var.common_tags}"
  asp_name     = "${var.product}-${var.env}${var.deployment_target}"
  asp_rg       = "${local.shared_infra_rg}${var.deployment_target}"
  instance_size = "I1"
  java_container_version = "9.0"
  java_version           = "11"
  
  appinsights_instrumentation_key = "${data.azurerm_key_vault_secret.appInsights-InstrumentationKey.value}"

  app_settings                         = {
    POSTGRES_HOST                      = "${data.azurerm_key_vault_secret.POSTGRES_HOST.value}"
    POSTGRES_PORT                      = "${data.azurerm_key_vault_secret.POSTGRES_PORT.value}"
    POSTGRES_DATABASE                  = "${data.azurerm_key_vault_secret.POSTGRES_DATABASE.value}"
    POSTGRES_USER                      = "${data.azurerm_key_vault_secret.POSTGRES-USER.value}"
    POSTGRES_PASSWORD                  = "${data.azurerm_key_vault_secret.POSTGRES-PASS.value}"
    WEBSITE_PROACTIVE_asp_name_ENABLED = "${var.autoheal}"
  }
}
data "azurerm_key_vault" "key_vault" {
  name                = "${local.vault_name}"
  resource_group_name = "${local.shared_infra_rg}"
}

data "azurerm_key_vault_secret" "appInsights-InstrumentationKey" {
  name      = "appInsights-InstrumentationKey"
  vault_uri = "${data.azurerm_key_vault.key_vault.vault_uri}"
}

data "azurerm_key_vault_secret" "POSTGRES-USER" {
  name      = "recipe-backend-POSTGRES-USER"
  vault_uri = "${data.azurerm_key_vault.key_vault.vault_uri}"
}

data "azurerm_key_vault_secret" "POSTGRES-PASS" {
  name      = "recipe-backend-POSTGRES-PASS"
  vault_uri = "${data.azurerm_key_vault.key_vault.vault_uri}"
}

data "azurerm_key_vault_secret" "POSTGRES_HOST" {
  name      = "recipe-backend-POSTGRES-HOST"
  vault_uri = "${data.azurerm_key_vault.key_vault.vault_uri}"
}

data "azurerm_key_vault_secret" "POSTGRES_PORT" {
  name      = "recipe-backend-POSTGRES-PORT"
  vault_uri = "${data.azurerm_key_vault.key_vault.vault_uri}"
}

data "azurerm_key_vault_secret" "POSTGRES_DATABASE" {
  name      = "recipe-backend-POSTGRES-DATABASE"
  vault_uri = "${data.azurerm_key_vault.key_vault.vault_uri}"
}

data "template_file" "api_template" {
  template = "${file("${path.module}/template/api.json")}"
}
/*
resource "azurerm_template_deployment" "api" {
  template_body       = "${data.template_file.api_template.rendered}"
  name                = "${var.product}-api-${var.env}"
  deployment_mode     = "Incremental"
  resource_group_name = "core-infra-${var.env}"
  count               = "${local.create_api ? 1 : 0}"

  parameters = {
    apiManagementServiceName  = "core-api-mgmt-${var.env}"
    apiName                   = "rhubarb-recipes-api"
    apiProductName            = "rhubarb-recipes"
    serviceUrl                = "http://${var.product}-${local.app}-${var.env}.service.${local.domain_name}"
    apiBasePath               = "${local.api_base_path}"
    policy                    = "${local.api_policy}"
  }
}
*/
