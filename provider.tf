# Configure the Azure provider
terraform {
/*
  backend "azurerm" {
    resource_group_name = "myTFResourceGroup"
    storage_account_name = "storage90accountname2343"
    container_name = "vhds"
    key = "terraform.tfstate"
  }*/
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }

}

provider "azurerm" {
  
  features {}
}
