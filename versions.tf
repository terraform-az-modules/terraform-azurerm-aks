terraform {
  required_version = ">= 1.10.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.31.0"
    }
  }

  provider_meta "azurerm" {
    module_name = "terraform-az-modules/terraform-azurerm-aks"
  }
}
