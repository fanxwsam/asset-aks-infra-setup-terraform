terraform {
  required_version = ">= 1.4.6"
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~> 3.54.0"
    }
  }

  # Terraform State Storage to Azure Storage Container
  backend "azurerm" {
    resource_group_name = "terraform-storage-rg"
    storage_account_name = "tfstateassetenv"
    container_name = "tfstatefiles"    
    key = "terraform-stackgres-dbcluster-internal.tfstate"
  }
}



module "stackgres-dbcluster" {
  source = "../modules/stackgres-dbcluster"
  
  # Different environment should have different environmen name
  environment = "internal"

  # namespace that APIs use
  # need to define here because APIs will access database using corresponding user name and password
  # the secret for APIs will be created when credentials are created for database
  api_ns = "asset-api"

  storage_account_rg = "data-backup-internal-rg"

  #!IMPORTANT: copy the name which created in '01-cloud-infra-internal'
  #The name is Azure Global Unique, so it is generated with a random ID
  storage_account_name = "databackinternalf08fe760"
}


