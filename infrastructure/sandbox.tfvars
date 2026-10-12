api_gateway_test_certificate_thumbprint = "4A98AB1CFFBA46CACBC7D8D3E10FDA667261DFAA"
rdb_backup_enabled                      = false
family                                  = "C"
sku_name                                = "Basic"
rdb_backup_max_snapshot_count           = "1"
# Lowest SKU only gives us 35 connections, we keep exhausting this causing pipeline failures.
# Set to B2s which has 414 max - should be enough for our usage, also set max_connections explicitly to 414.
pgsql_sku     = "B_Standard_B2s"
pgsql_version = "14"
pgsql_server_configuration = {
  name  = "max_connections"
  value = "414"
}
# DTSPO-32691: temporarily disabled with the App Service Plan module.
# asp_sku_size                            = "B1"
# asp_capacity                            = 1
