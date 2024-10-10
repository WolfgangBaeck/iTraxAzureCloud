
terraform {
  required_version = ">= 1.5.7, < 2.0.0"

  backend "azurerm" {
    # resource_group_name  = "#{RGN}#" 
    # storage_account_name = "#{SAN}#" 
    # container_name       = "#{CN}#" 
    # subscription_id      = "#{SUB}#"
  backend "azurerm" {
    resource_group_name   = "rg-tfstate"
    storage_account_name  = "stohopeandhometfstates"
    container_name        = "cont-hah-tfstate"
    key                   = "terraform.tfstate"
  }
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.73.0, < 4.4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.1, < 4.4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "c056d029-5e26-4859-b02c-35e4714819c7"
}

# provider "azurerm" {
#   alias           = "backup_sub_provider"
#   subscription_id = "#{BACKSUB}#"
#   features {
    
#   }
# }
