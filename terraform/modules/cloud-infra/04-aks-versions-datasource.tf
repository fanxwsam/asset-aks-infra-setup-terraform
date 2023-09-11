# Use this data source to retrieve the version of Kubernetes supported by Azure Kubernetes Service.
data "azurerm_kubernetes_service_versions" "current" {
  location = azurerm_resource_group.aks-cluster-rg.location
  include_preview = false
}