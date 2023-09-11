# Create log Analytics Workplace 
resource "azurerm_log_analytics_workspace" "insights" {
  name                = "${var.environment}-log-analytics-workspace-${random_pet.aksrandom.id}"
  location            = azurerm_resource_group.aks-cluster-rg.location
  resource_group_name = azurerm_resource_group.aks-cluster-rg.name
  retention_in_days   = 30
}

# Create Log Analytics Workspace for enabling Monitoring Add On during AKS Cluster creation  
resource "azurerm_log_analytics_solution" "analytics_solution" {
  location              = azurerm_log_analytics_workspace.insights.location
  resource_group_name   = azurerm_resource_group.aks-cluster-rg.name
  solution_name         = "ContainerInsights"
  workspace_name        = azurerm_log_analytics_workspace.insights.name
  workspace_resource_id = azurerm_log_analytics_workspace.insights.id

  plan {
    product   = "OMSGallery/ContainerInsights"
    publisher = "Microsoft"
  }
}