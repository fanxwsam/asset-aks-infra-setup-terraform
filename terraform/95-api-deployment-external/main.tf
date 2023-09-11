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
    key = "terraform-api-deployment-external.tfstate"
  }
}


module "api-deployment" {
  source = "../modules/api-deployment"  
  app-namespace = "asset-external"
  asset-sc = "asset-sc-external"
  asset-pv = "asset-pv-external"
  zookeeper-nodeport = "30182"
  rabbitmq-nodeport-http = "31673"
  rabbitmq-nodeport-amqp = "30673"
  zipkin-ingress-host = "zipkin-ext.kubedev.link"
  apigw-ingress-host = "api-ext.kubedev.link"
  security-ingress-host = "auth-ext.kubedev.link"
  users-dataSource-database = "dGthaGlkYg=="
  users-dataSource-key = "TTRWNXJXWHpBZFl2MFQzaDA2Y0JNSXQ0a0VmYlhNaTR2VWU0d2x4YjFUMlN0OTcybVA3YVpuOGNZcmV1ZkpWdG4wZXpCSHp4YWlsVEFDRGJJVDFQdWc9PQ=="
  users-dataSource-uri = "aHR0cHM6Ly9haGktYmhhLWNvc21vcy1kZXYuZG9jdW1lbnRzLmF6dXJlLmNvbTo0NDMv"
}