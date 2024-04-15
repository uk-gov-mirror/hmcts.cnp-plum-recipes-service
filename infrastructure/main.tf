provider "azurerm" {
  features {}
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
  alias                      = "postgres_network"
  subscription_id            = var.aks_subscription_id
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

resource "azurerm_key_vault_secret" "POSTGRES-USER-V14" {
  name         = "recipe-backend-POSTGRES-USER-v14"
  value        = module.postgresql_flexible.username
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "POSTGRES-PASS-V14" {
  name         = "recipe-backend-POSTGRES-PASS-v14"
  value        = module.postgresql_flexible.password
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "POSTGRES_HOST-V14" {
  name         = "recipe-backend-POSTGRES-HOST-V14"
  value        = module.postgresql_flexible.fqdn
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "POSTGRES_PORT-V14" {
  name         = "recipe-backend-POSTGRES-PORT-V14"
  value        = "5432"
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "POSTGRES_DATABASE-V14" {
  name         = "recipe-backend-POSTGRES-DATABASE-V14"
  value        = "rhubarb"
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

module "postgresql_flexible" {
  providers = {
    azurerm.postgres_network = azurerm.postgres_network
  }

  source        = "git@github.com:hmcts/terraform-module-postgresql-flexible?ref=master"
  env           = var.env
  product       = var.product
  name          = "${var.product}-v14-flexible"
  component     = var.component
  business_area = "CFT"
  location      = var.location
  subnet_suffix = "expanded"

  common_tags          = var.common_tags
  admin_user_object_id = var.jenkins_AAD_objectId
  pgsql_databases = [
    {
      name : "plum"
    },
    {
      name : "rhubarb"
    }
  ]

  pgsql_version = "16"
}

# region API (gateway)

module "plum_product" {
  source = "git@github.com:hmcts/cnp-module-api-mgmt-product?ref=master"

  api_mgmt_name = "core-api-mgmt-${var.env}"
  api_mgmt_rg   = "core-infra-${var.env}"

  name = "plum-recipes"
}

module "api" {
  source         = "git@github.com:hmcts/cnp-module-api-mgmt-api?ref=master"
  name           = "${var.product}-recipes-api"
  api_mgmt_rg    = "core-infra-${var.env}"
  api_mgmt_name  = "core-api-mgmt-${var.env}"
  display_name   = "${var.product}-recipes"
  revision       = "1"
  product_id     = module.plum_product.product_id
  path           = local.api_base_path
  service_url    = "http://${var.product}-${local.app}-${var.env}.service.core-compute-${var.env}.internal"
  swagger_url    = "https://raw.githubusercontent.com/hmcts/reform-api-docs/master/docs/specs/cnp-plum-recipes-service.json"
  content_format = "openapi+json-link"
}

module "policy" {
  source                 = "git@github.com:hmcts/cnp-module-api-mgmt-api-policy?ref=master"
  api_mgmt_name          = "core-api-mgmt-${var.env}"
  api_mgmt_rg            = "core-infra-${var.env}"
  api_name               = module.api.name
  api_policy_xml_content = local.api_policy
}
# endregion

# REDIS CACHE TESTING

variable "rdb_backup_enabled" {
  type    = bool
  default = false
}

variable "sku_name" {
  default     = "Basic"
  description = "The SKU of Redis to use. Possible values are `Basic`, `Standard` and `Premium`."
}

variable "family" {
  default     = "C"
  description = "The SKU family/pricing group to use. Valid values are `C` (for Basic/Standard SKU family) and `P` (for Premium). Use P for higher availability, but beware it costs a lot more."
}

variable "redis_capacity" {
  default     = "1"
  description = "The size of the Redis cache to deploy. Valid values are 1, 2, 3, 4, 5"
}

variable "redis_backup_frequency" {
  default     = "360"
  description = "The Backup Frequency in Minutes. Only supported on Premium SKUs. Possible values are: 15, 30, 60, 360, 720 and 1440"
}

module "plum-redis-storage" {
  source                          = "git@github.com:hmcts/cnp-module-redis?ref=DTSPO-17012-data-persistency"
  product                         = "${var.product}-${var.component}-session-storage"
  location                        = var.location
  env                             = var.env
  private_endpoint_enabled        = true
  redis_version                   = "6"
  business_area                   = "cft"
  public_network_access_enabled   = false
  common_tags                     = var.common_tags
  sku_name                        = var.sku_name
  family                          = var.family
  capacity                        = var.redis_capacity
  rdb_backup_enabled              = var.rdb_backup_enabled
  rdb_backup_frequency            = var.redis_backup_frequency
  rdb_storage_account_name_prefix = var.product
}
