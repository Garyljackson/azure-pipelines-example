terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.70.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  resource_group_name = "cx-affinity-kiosk-${var.environment_name}"
  custom_domain       = var.environment_name == lower("prod") ? "affinity-kiosk-um.connectexpress.com.au" : "affinity-kiosk-um-${var.environment_name}.connectexpress.com.au"
}

resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = var.resource_group_location
}

data "azurerm_container_registry" "main" {
  name                = "connectdevelop"
  resource_group_name = "Shared-Resources"
}

