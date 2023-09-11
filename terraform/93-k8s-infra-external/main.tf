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
    key = "terraform-k8s-infra-external.tfstate"
  }
}



module "k8s-infra" {
  source = "../modules/k8s-infra"

  # Different environment should have different DNS Zone
  # public DNS Zone
  az_dns_zone_name = "kubedev.link"
  
  # public DNS Zone resource group
  az_dns_zone_rg_name ="dns-zone"
  
  # Different environment should have different private DNS Zone resource group
  # private DNS Zone resource group
  az_private_dns_zone_rg_name = "dns-zone-private"
  
  # Different environment should have different name
  aks_cluster_issuer_sp_name = "aks_ci_sp_external"
  
  # Different environment should have different environmen name
  environment = "external"
  
  # Different environment should have different cluster name
  aks_cluster_name = "aks-external-cluster"
  
  # Different environment should have different cluster node name
  aks_cluster_node_rg_name =  "aks-external-node-rg"  
  
  aks_grafana_admin_user = "admin"
  
  aks_grafana_admin_password = "p@sSw0rd$1%-#1"

  linkerd_viz_host = "linkerd.kubedev.link"

  metrics_dashboard_host = "dashboard.kubedev.link"
 
  grafana_host = "grafana.kubedev.link"

  prometheus_host = "prometheus.kubedev.link"

  stackgres_host = "stackgres.kubedev.link"

}