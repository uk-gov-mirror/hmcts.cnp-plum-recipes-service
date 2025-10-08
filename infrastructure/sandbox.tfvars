# Basic configuration
component    = "recipe-backend"
env          = "sandbox"
subscription = "sandbox"
tenant_id    = "531ff96d-0ae9-462a-8d2d-bec7c0b42082"

aks_subscription_id = "b72ab7b7-723f-4b18-b6f6-03b0f2c6a1bb"

# Common tags
common_tags = {
  "application"  = "plum-recipe-backend"
  "businessArea" = "CFT"
  "builtFrom"    = "cnp-plum-recipes-service"
  "environment"  = "sandbox"
}

# Application configuration
api_gateway_test_certificate_thumbprint = "4A98AB1CFFBA46CACBC7D8D3E10FDA667261DFAA"

# Redis configuration
rdb_backup_enabled            = true
family                        = "P"
sku_name                      = "Premium"
rdb_backup_max_snapshot_count = "1"
availability_zones            = ["1", "2", "3"]

# PostgreSQL configuration
pgsql_sku = "B_Standard_B1ms"

jenkins_AAD_objectId = "0292f26e-288e-4f5b-85fc-b99a53f0a2b1"
