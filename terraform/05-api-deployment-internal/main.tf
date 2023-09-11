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
    key = "terraform-api-deployment-internal.tfstate"
  }
}


module "api-deployment" {
  source = "../modules/api-deployment"  
  app-namespace = "asset-internal"
  asset-sc = "asset-sc-internal"
  asset-pv = "asset-pv-internal"
  zookeeper-nodeport = "30183"
  rabbitmq-nodeport-http = "31672"
  rabbitmq-nodeport-amqp = "30672"
  zipkin-ingress-host = "zipkin-int.samsassets.com"
  apigw-ingress-host = "api-int.samsassets.com"
  security-ingress-host = "auth-int.samsassets.com"
  users-dataSource-database = "dGthaGlkYg=="
  users-dataSource-key = "TTRWNXJXWHpBZFl2MFQzaDA2Y0JNSXQ0a0VmYlhNaTR2VWU0d2x4YjFUMlN0OTcybVA3YVpuOGNZcmV1ZkpWdG4wZXpCSHp4YWlsVEFDRGJJVDFQdWc9PQ=="
  users-dataSource-uri = "aHR0cHM6Ly9haGktYmhhLWNvc21vcy1kZXYuZG9jdW1lbnRzLmF6dXJlLmNvbTo0NDMv"
}