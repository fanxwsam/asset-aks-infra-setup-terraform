# generate public ip address for public ingress
resource "azurerm_public_ip" "aks_cluster_ingress_public_ip" {
  name                = "${azurerm_kubernetes_cluster.aks_cluster.name}_ingress_public_ip"
  resource_group_name = azurerm_kubernetes_cluster.aks_cluster.node_resource_group
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [1, 2, 3]  
}