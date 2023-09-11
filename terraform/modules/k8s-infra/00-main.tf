terraform {
  # backend "azurerm" {
  #   resource_group_name = "terraform-storage-rg"
  #   storage_account_name = "tfstateassetenv"
  #   container_name = "tfstatefiles"
  #   key = "terraform-k8s-infra.tfstate"
  # }

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
  
}

provider "kubernetes" {  
  config_path ="~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "azurerm" {
    features {
      
    }  
}

