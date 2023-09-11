/* 
  Create Azure Virtual Network
  Create Four subnets:
        one for 'system' node pool of AKS Cluster 
        and others for the 'user' node pools and Azure Virtual Nodes
  */

# Virtual network
resource "azurerm_virtual_network" "aks-vnet" {
  name                = "aks-${var.environment}-vnet"
  address_space       = [var.aks_vnet_address_space]
  location            = azurerm_resource_group.aks-cluster-rg.location
  resource_group_name = azurerm_resource_group.aks-cluster-rg.name
}

# Default subnet
resource "azurerm_subnet" "aks-subnet-default" {
  name                 = "aks-${var.environment}-subnet-default"
  resource_group_name  = azurerm_resource_group.aks-cluster-rg.name
  virtual_network_name = azurerm_virtual_network.aks-vnet.name
  address_prefixes     = [var.aks_subnet_default_address_space] 
}

# API subnet
resource "azurerm_subnet" "aks-subnet-api" {
  name                 = "aks-${var.environment}-subnet-api"
  resource_group_name  = azurerm_resource_group.aks-cluster-rg.name
  virtual_network_name = azurerm_virtual_network.aks-vnet.name
  address_prefixes     = [var.aks_subnet_api_address_space] 
}

# Database Cluster subnet
resource "azurerm_subnet" "aks-subnet-dbcluster" {
  name                 = "aks-${var.environment}-subnet-dbcluster"
  resource_group_name  = azurerm_resource_group.aks-cluster-rg.name
  virtual_network_name = azurerm_virtual_network.aks-vnet.name
  address_prefixes     = [var.aks_subnet_dbcluster_address_space] 
}

# Virtual Nodes subnet
resource "azurerm_subnet" "aks-subnet-virtual-nodes" {
  name                 = "aks-${var.environment}-subnet-virtual-nodes"
  resource_group_name  = azurerm_resource_group.aks-cluster-rg.name
  virtual_network_name = azurerm_virtual_network.aks-vnet.name
  address_prefixes     = [var.aks_subnet_virtual_nodes_address_space] 
}

# Private DNS Zone has the same domain name as the public DNS Zone
resource "azurerm_private_dns_zone" "az_private_dns_zone" {
  name                = var.az_dns_zone_name
  resource_group_name = azurerm_resource_group.az-private-dns-zone-rg.name
}