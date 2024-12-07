terraform {
  required_version = "~> 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.13.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "<subscription_id>"
  features {}
}
