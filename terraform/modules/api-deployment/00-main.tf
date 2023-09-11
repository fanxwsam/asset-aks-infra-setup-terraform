terraform {
  # backend "azurerm" {
  #   resource_group_name = "terraform-storage-rg"
  #   storage_account_name = "tfstateassetenv"
  #   container_name = "tfstatefiles"
  #   key = "terraform-stackgres-dbcluster-internal.tfstate"
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


data "template_file" "asset_chart_template" {
  template = "${file("${path.module}/asset-chart-template.yaml")}"

  vars = {          
          app-namespace = var.app-namespace
          asset-sc = var.asset-sc
          asset-pv = var.asset-pv
          zookeeper-nodeport = var.zookeeper-nodeport
          rabbitmq-nodeport-http = var.rabbitmq-nodeport-http
          rabbitmq-nodeport-amqp = var.rabbitmq-nodeport-amqp
          zipkin-ingress-host = var.zipkin-ingress-host
          apigw-ingress-host = var.apigw-ingress-host
          security-ingress-host = var.security-ingress-host
          users-dataSource-database = var.users-dataSource-database
          users-dataSource-key = var.users-dataSource-key
          users-dataSource-uri = var.users-dataSource-uri
  }
}


resource "helm_release" "asset_api" {
  name       = "asset-api"
  chart      = "${path.module}/asset-chart"  
  
  values     = [data.template_file.asset_chart_template.rendered]
}