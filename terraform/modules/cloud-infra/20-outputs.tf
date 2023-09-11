output "resource-group-location-cluster" {
    value = azurerm_resource_group.aks-cluster-rg.location  
}

output "resource-group-name-cluster" {
    value = azurerm_resource_group.aks-cluster-rg.name
}

output "resource-group-id-cluster" {
    value = azurerm_resource_group.aks-cluster-rg.id
}

# output "versions" {
#   value = data.azurerm_kubernetes_service_versions.current.versions
# }

output "latest-version" {
  value = data.azurerm_kubernetes_service_versions.current.latest_version
}

output "azuread-group-id" {
    value = azuread_group.aks_administrators.id
  
}

output "aks-cluster-id" {
    value = azurerm_kubernetes_cluster.aks_cluster.id  
}

output "aks-cluster-name" {
    value = azurerm_kubernetes_cluster.aks_cluster.name  
}

output "aks-cluster-kubernetes_version" {
    value = azurerm_kubernetes_cluster.aks_cluster.kubernetes_version
}

output "aks-vnet-id" {
    value = azurerm_virtual_network.aks-vnet.id  
}

output "aks-subnet-default-id" {
    value = azurerm_subnet.aks-subnet-default.id  
}

output "aks-subnet-api-id" {
    value = azurerm_subnet.aks-subnet-api.id
}

output "aks-subnet-dbcluster-id" {
    value = azurerm_subnet.aks-subnet-dbcluster.id
}

output "aks-subnet-virtual-nodes-id" {
    value = azurerm_subnet.aks-subnet-virtual-nodes.id
}

output "subscription_id"{
    value = data.azurerm_subscription.current.id
}

output "tenant_id"{
    value         = data.azurerm_client_config.current.tenant_id
}

output "aks_sp_cluster_issuer_object_id" {
    value = azuread_service_principal.cluster_issuer_sp.object_id
}


output "aks_sp_cluster_issuer_password_sp_application_id" {
    value = azuread_service_principal.cluster_issuer_sp.application_id
}

output "aks_sp_cluster_issuer_password_sp_id" {
    value = azuread_service_principal.cluster_issuer_sp.id
}


output "az_dns_zone_az1_asset_id" {
    value = data.azurerm_dns_zone.dns_zone_az1_asset.id
}




output "azurerm_user_assigned_identity_client_id" {
    value = data.azurerm_user_assigned_identity.managed_identity_agent_pool.client_id
   
}

output "azurerm_user_assigned_identity_principal_id" {
    value = data.azurerm_user_assigned_identity.managed_identity_agent_pool.principal_id
   
}



output "vnet_id" {
  value = azurerm_virtual_network.aks-vnet.id
}


output "aks_cluster_principal_id" {    
    value       =  azurerm_kubernetes_cluster.aks_cluster.identity[0].principal_id
}

output "az_aks_get_credentials" {
    value = "az aks get-credentials -g ${azurerm_resource_group.aks-cluster-rg.name} -n ${azurerm_kubernetes_cluster.aks_cluster.name} --overwrite-existing --admin"
}

output "data_backup_storage_acount_name" {
    value = azurerm_storage_account.data_backup_storage_acount.name
}    