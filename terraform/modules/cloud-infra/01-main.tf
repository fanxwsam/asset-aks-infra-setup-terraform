terraform {
  required_version = ">= 1.4.6"
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~> 3.54.0"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "~> 2.38.0"
    }
    random = {
      source = "hashicorp/random"
      version = "~> 3.5.1"
    }
  }

  # Terraform State Storage to Azure Storage Container
  # backend "azurerm" {
  #   resource_group_name = "terraform-storage-rg"
  #   storage_account_name = "tfstateassetenv"
  #   container_name = "tfstatefiles"
  #   # key = "terraform-cloud-infra.tfstate"
  #   key = "terraform-cloud-infra-${var.environment}.tfstate"
  # }
}

provider "azurerm" {
    features {
      
    }  
}

resource "random_pet" "aksrandom" {
  
}

resource "random_id" "storage_account_suffix" {
  byte_length = 4
}
