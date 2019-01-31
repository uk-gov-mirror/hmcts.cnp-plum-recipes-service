variable "product" {
  type    = "string"
  default = "plum"
}

variable "location" {
  type    = "string"
  default = "UK South"
}

variable "env" {
  type = "string"
}

variable "subscription" {
  type = "string"
}
variable "ilbIp"{}


variable "capacity" {
  default = "1"
}
variable "common_tags" {
  type = "map"
}

variable "autoheal" {
  description = "Enabling Proactive Auto Heal for Webapps"
  type        = "string"
  default     = "True"
}

variable deployment_target {
}

# thumbprint of the SSL certificate for API gateway tests
variable api_gateway_test_certificate_thumbprint {
  type    = "string"
  # keeping this empty by default, so that no thumbprint will match
  default = ""
}