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
    key = "terraform-cloud-infra-internal.tfstate"
  }
}



module "cloud-infra" {
  source = "../modules/cloud-infra"

  location = "australiaeast"
  environment = "internal"
  ssh_public_key = "aks-internal-sshkey.pub"
  aks_dns_service_ip = "10.10.240.10"
  aks_service_cidr = "10.10.240.0/20"
  aks_vnet_address_space = "10.10.0.0/16"
  aks_subnet_default_address_space = "10.10.0.0/20"
  aks_subnet_api_address_space = "10.10.16.0/20"
  aks_subnet_dbcluster_address_space = "10.10.32.0/20"
  aks_subnet_virtual_nodes_address_space = "10.10.48.0/20"
  
  aks_k8s_version = "1.25.6"
  
  # public DNS Zone
  az_dns_zone_name = "samsassets.com"
  
  # public DNS Zone
  az_dns_zone_resource_group_name = "dns-zone"
  
  # private DNS Zone
  resource_group_name_private_dns_zone = "dns-zone-private-int"
  
  # Different environment should have different name
  aks_cluster_issuer_sp_name = "aks_ci_sp_internal"
}

output "az_aks_get_credentials" {
  value = module.cloud-infra.az_aks_get_credentials
}

# this output will be used when deploy Stackgres DB cluster, it is used for database backup
output "data_backup_storage_acount_name" {
  value = module.cloud-infra.data_backup_storage_acount_name
}
