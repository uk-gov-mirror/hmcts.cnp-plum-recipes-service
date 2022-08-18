provider "azurerm" {
  features {}
}

locals {
  app        = "recipe-backend"
  create_api = var.env != "preview" && var.env != "spreview"

  # list of the thumbprints of the SSL certificates that should be accepted by the API (gateway)
  allowed_certificate_thumbprints = [
    # API tests
    var.api_gateway_test_certificate_thumbprint,
    "8B0666A1041156C83BCE832906F9BC7C2542B65A"
  ]

  thumbprints_in_quotes     = formatlist("&quot;%s&quot;", local.allowed_certificate_thumbprints)
  thumbprints_in_quotes_str = join(",", local.thumbprints_in_quotes)
  api_policy                = replace(file("template/api-policy.xml"), "ALLOWED_CERTIFICATE_THUMBPRINTS", local.thumbprints_in_quotes_str)
  api_base_path             = "${var.product}-recipes-api"
  shared_infra_rg           = "${var.product}-shared-infrastructure-${var.env}"
  vault_name                = "${var.product}si-${var.env}"
}

data "azurerm_subnet" "postgres" {
  name                 = "core-infra-subnet-0-${var.env}"
  resource_group_name  = "core-infra-${var.env}"
  virtual_network_name = "core-infra-vnet-${var.env}"
}

data "azurerm_key_vault" "key_vault" {
  name                = local.vault_name
  resource_group_name = local.shared_infra_rg
}

resource "azurerm_key_vault_secret" "POSTGRES-USER-V11" {
  name         = "recipe-backend-POSTGRES-USER-v11"
  value        = module.recipe-database-v11.user_name
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "POSTGRES-PASS-V11" {
  name         = "recipe-backend-POSTGRES-PASS-v11"
  value        = module.recipe-database-v11.postgresql_password
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "POSTGRES_HOST-V11" {
  name         = "recipe-backend-POSTGRES-HOST-v11"
  value        = module.recipe-database-v11.host_name
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "POSTGRES_PORT-V11" {
  name         = "recipe-backend-POSTGRES-PORT-v11"
  value        = module.recipe-database-v11.postgresql_listen_port
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "POSTGRES_DATABASE-V11" {
  name         = "recipe-backend-POSTGRES-DATABASE-v11"
  value        = module.recipe-database-v11.postgresql_database
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

module "recipe-database-v11" { 
  source             = "git@github.com:hmcts/cnp-module-postgres?ref=postgresql_tf"
  product            = var.product
  name               = "${var.product}-v11"
  location           = var.location
  env                = var.env
  postgresql_user    = "rhubarbadmin"
  database_name      = "rhubarb"
  postgresql_version = "11"

  subnet_id          = data.azurerm_subnet.postgres.id
  sku_name           = "GP_Gen5_2"
  sku_tier           = "GeneralPurpose"
  storage_mb         = "51200"
  common_tags        = var.common_tags
  subscription       = var.subscription
}

# region API (gateway)

module "plum_product" {
  source = "git@github.com:hmcts/cnp-module-api-mgmt-product?ref=master"

  api_mgmt_name = "core-api-mgmt-${var.env}"
  api_mgmt_rg   = "core-infra-${var.env}"

  name = "plum-recipes"
}

module "api" {
  source        = "git@github.com:hmcts/cnp-module-api-mgmt-api?ref=master"
  name          = "${var.product}-recipes-api"
  api_mgmt_rg   = "core-infra-${var.env}"
  api_mgmt_name = "core-api-mgmt-${var.env}"
  display_name  = "${var.product}-recipes"
  revision      = "1"
  product_id    = module.plum_product.product_id
  path          = local.api_base_path
  service_url   = "http://${var.product}-${local.app}-${var.env}.service.core-compute-${var.env}.internal"
  swagger_url   = "https://raw.githubusercontent.com/hmcts/reform-api-docs/master/docs/specs/cnp-plum-recipes-service.json"
}

module "policy" {
  source                 = "git@github.com:hmcts/cnp-module-api-mgmt-api-policy?ref=master"
  api_mgmt_name          = "core-api-mgmt-${var.env}"
  api_mgmt_rg            = "core-infra-${var.env}"
  api_name               = module.api.name
  api_policy_xml_content = local.api_policy
}
# endregion

