# Cluster resource group
resource "azurerm_resource_group" "aks-cluster-rg" {
    name = "${var.resource_group_name_cluster_prefix}-${var.environment}-rg"
    location = var.location
}

# Private DNS resource group - Public DNS resouce group has been created manually and is being used, so will not create these resources
resource "azurerm_resource_group" "az-private-dns-zone-rg" {    
    name = var.resource_group_name_private_dns_zone
    location = var.location
}

# resource group for database backup
resource "azurerm_resource_group" "data_backup" {
  name     = "data-backup-${var.environment}-rg"
  location = var.location
}