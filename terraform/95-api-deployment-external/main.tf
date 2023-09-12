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
  image-version = "2.5"
  users-dataSource-database = "YXNzZXQtZGVtbw=="
  users-dataSource-key = "TUZnaXBJNnA5d2RLdExuZUxVUkpIMHV4Q1NYaExKMHV2ZjZNMzdFaUlXRjRTclI1RU1lWUVuQklZUXlpUlVTc21FNFJCTkJqWTl4ZUFDRGJ4WWtteHc9PQ=="
  users-dataSource-uri = "aHR0cHM6Ly9hc3NldC5kb2N1bWVudHMuYXp1cmUuY29tOjQ0My8="  
}