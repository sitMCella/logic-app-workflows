variable "location" {
  description = "Location of the Azure resources."
  type        = string
}

variable "location_short" {
  description = "Location short name for the Axzure resources, for example: weu."
  type        = string
}

variable "environment" {
  description = "Environment name, for example: test, prod."
  type        = string
}

variable "subscription_id" {
  description = "Subscription ID."
  type        = string
}

variable "time_zone" {
  description = "Time Zone."
  type        = string
}

variable "tags" {
  description = "Tags map."
  type        = map(string)
}
