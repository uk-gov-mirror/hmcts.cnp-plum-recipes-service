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

data "azurerm_subnet" "redis_private_endpoint" {
  name                 = "core-infra-subnet-2-${var.env}"
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

  source            = "git@github.com:hmcts/terraform-module-postgresql-flexible?ref=DTSPO-30107-additional-postgres-admins"
  env               = var.env
  product           = var.product
  name              = "${var.product}-v14-flexible"
  component         = var.component
  business_area     = "CFT"
  location          = var.location
  subnet_suffix     = "expanded"
  high_availability = var.env == "perftest" || var.env == "test" ? false : null

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

  pgsql_version    = "16"
  pgsql_sku        = var.pgsql_sku
  pgsql_storage_mb = var.env == "sandbox" ? 131072 : null

  service_criticality = var.service_criticality
  backup_policy_id    = var.backup_policy_id
}

# endregion

# DTSPO-32691: temporarily disabled to destroy the unused sandbox App Service Plan.
# Re-enable (uncomment) to recreate it.
# module "app_service_plan" {
#   source = "git@github.com:hmcts/cnp-module-app-service-plan?ref=master"
#
#   asp_name            = var.product
#   env                 = var.env
#   location            = var.location
#   resource_group_name = local.shared_infra_rg
#   asp_sku_size        = var.asp_sku_size
#   asp_capacity        = var.asp_capacity
#   common_tags         = var.common_tags
# }

resource "azurerm_key_vault_secret" "redis_connection_string" {
  name         = "redis-connection-string"
  value        = "rediss://default:${urlencode(module.managed_redis[var.env].primary_access_key)}@${module.managed_redis[var.env].hostname}:${module.managed_redis[var.env].port}"
  key_vault_id = data.azurerm_key_vault.plum_key_vault.id
}
data "azurerm_key_vault" "plum_key_vault" {
  name                = "plumsi-${var.env}"
  resource_group_name = "plum-shared-infrastructure-${var.env}"
}


module "managed_redis" {
  for_each = toset([var.env])
  source   = "git@github.com:hmcts/terraform-module-azure-managed-redis?ref=main"

  product     = var.product
  component   = var.component
  env         = var.env
  location    = var.location
  common_tags = var.common_tags

  sku_name = "Balanced_B0"

  public_network_access   = "Disabled"
  create_private_endpoint = true
  subnet_id               = data.azurerm_subnet.redis_private_endpoint.id
  private_dns_zone_ids    = ["/subscriptions/${var.private_dns_subscription_id}/resourceGroups/core-infra-intsvc-rg/providers/Microsoft.Network/privateDnsZones/privatelink.redis.azure.net"]

  access_keys_authentication_enabled = true
  persistence_rdb_backup_frequency   = "6h"
}
