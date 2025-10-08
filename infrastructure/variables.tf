variable "product" {
  default = "plum"
}

variable "component" {}

variable "location" {
  default = "UK South"
}

variable "env" {
}

variable "subscription" {
}

variable "tenant_id" {}

variable "jenkins_AAD_objectId" {
  description = "(Required) The Azure AD object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies."
}

variable "aks_subscription_id" {}

variable "capacity" {
  default = "1"
}

variable "common_tags" {
  type = map(string)
}

# thumbprint of the SSL certificate for API gateway tests
variable "api_gateway_test_certificate_thumbprint" {
  # keeping this empty by default, so that no thumbprint will match
  default = ""
}

variable "autoheal" {
  description = "Enabling Proactive Auto Heal for Webapps"
  default     = "True"
}

variable "private_dns_subscription_id" {
  default = "1baf5470-1c3e-40d3-a6f7-74bfbce4b348"
}

variable "pgsql_sku" {
  default = "GP_Standard_D2s_v3"
}

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

variable "rdb_backup_max_snapshot_count" {
  type    = string
  default = "1"
}

variable "availability_zones" {
  type        = list(string)
  default     = []
  description = "Specifies a list of Availability Zones in which this Redis Cache should be located. Changing this forces a new Redis Cache to be created."
}
