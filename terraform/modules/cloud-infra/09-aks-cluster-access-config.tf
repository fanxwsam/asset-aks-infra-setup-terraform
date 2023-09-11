# After the cluster adminitrator group is created, roles will be assigned to it 
# so that the users in this group can manage AKS
data "azurerm_role_definition" "aks_cluster_user" {
  name = "Azure Kubernetes Service Cluster User Role"
}

# assign cluster user role to clster
resource "azurerm_role_assignment" "aks_cluster_admin_group_role" {
  scope                = azurerm_kubernetes_cluster.aks_cluster.id  
  role_definition_name = data.azurerm_role_definition.aks_cluster_user.name
  principal_id         = azuread_group.aks_administrators.object_id
}

data "azurerm_dns_zone" "dns_zone_az1_asset" {
  name                = var.az_dns_zone_name
  resource_group_name = var.az_dns_zone_resource_group_name
}

data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}
data "azuread_client_config" "current" {}

# create a service principal which is used for cert manager cluster issuer
# resource "null_resource" "create_sp_cluster_issuer" {
#   depends_on = [null_resource.get_credentials_created_cluster]

#   provisioner "local-exec" {
#     command="az ad sp create-for-rbac --name ${var.aks_cluster_issuer_sp_name}"
#   }
# }

# create a service principal which is used for cert manager cluster issuer
resource "azuread_application" "cluster_issuer_app" {
  display_name = var.aks_cluster_issuer_sp_name
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "cluster_issuer_sp" {
  application_id               = azuread_application.cluster_issuer_app.application_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}


# add the cluster issuer application
#  resource "azuread_application" "aks_app_cluster_issuer" {
#    //display_name = "cluster_issuer_app"
#    display_name = var.aks_cluster_issuer_sp_name
#  }

# data "azuread_service_principal" "aks_sp_cluster_issuer" {
#   display_name = var.aks_cluster_issuer_sp_name
#   depends_on = [null_resource.create_sp_cluster_issuer]
# }

# data "azuread_application" "aks_app_cluster_issuer" {
#   display_name = var.aks_cluster_issuer_sp_name
#   depends_on = [null_resource.create_sp_cluster_issuer]
# }


# resource "azuread_application_password" "example" {
#   application_object_id = data.azuread_application.aks_app_cluster_issuer.object_id  
#   end_date              = "2030-01-01T01:00:00Z"
# }

# resource "null_resource" "role_assignment_sp_cluster_issuer" {
#   depends_on = [azuread_application.aks_app_cluster_issuer]

#   provisioner "local-exec" {
#     command="az role assignment create --assignee ${data.azuread_application.aks_app_cluster_issuer.application_id} --role ${jsonencode(var.az_dns_zone_role_assign)} --scope ${data.azurerm_dns_zone.dns_zone_az1_asset.id}"
#   }
# }

# assign role 'DNS Zone Contributor' to the service princal
# so that cluster issuer of cert manager can access the public dns zone
# to issue a Certificate when challenge happens
resource "azurerm_role_assignment" "assignment_sp" {
  # principal_id                     = data.azuread_application.aks_app_cluster_issuer.application_id
  principal_id                     = azuread_service_principal.cluster_issuer_sp.object_id
  scope                            = data.azurerm_dns_zone.dns_zone_az1_asset.id
  role_definition_name             = "DNS Zone Contributor"
  skip_service_principal_aad_check = true
  depends_on = [azuread_service_principal.cluster_issuer_sp]
}


data "azurerm_user_assigned_identity" "managed_identity_agent_pool" {
  name                = "${azurerm_kubernetes_cluster.aks_cluster.name}-agentpool"
  
  resource_group_name = azurerm_kubernetes_cluster.aks_cluster.node_resource_group
}

data "azurerm_resource_group" "az_dns_zone_rg" {    
    name = var.az_dns_zone_resource_group_name
}

# data "azurerm_resource_group" "az_private_dns_zone_rg" {    
#     name = var.resource_group_name_private_dns_zone
# }


# configure managed identity cluster 'agent pool' to have role 'Contributor' on public azure dns resource group
# External DNS will be configured to use this managed identity to access azure DNS Zone
# so that External DNS can access the public DNS Zone
resource "azurerm_role_assignment" "assignment_mi" {
  principal_id                     = data.azurerm_user_assigned_identity.managed_identity_agent_pool.principal_id
  scope                            = data.azurerm_resource_group.az_dns_zone_rg.id
  role_definition_name             = "Contributor"
  skip_service_principal_aad_check = true
  depends_on = [azuread_service_principal.cluster_issuer_sp]
}

# configure managed identity cluster 'agent pool' to have role 'Contributor' on private azure dns resource group
# External DNS will be configured to use this managed identity to access azure DNS Zone
# so that External DNS can access the public DNS Zone
resource "azurerm_role_assignment" "assignment_mi_private_dns_zone" {
  principal_id                     = data.azurerm_user_assigned_identity.managed_identity_agent_pool.principal_id
  scope                            = azurerm_resource_group.az-private-dns-zone-rg.id
  role_definition_name             = "Contributor"
  skip_service_principal_aad_check = true
  depends_on = [azuread_service_principal.cluster_issuer_sp]
}

# !Important
# Permission grants to cluster Managed Identity used by Azure Cloud provider may take up 60 minutes to populate.
# Without this role, internal nginx ingress service cannot get a private ip address
# It happens when we create an AKS cluster with specific vnet and enabled CNI feature.
resource "azurerm_role_assignment" "assignment_vnet" {
  principal_id                     = azurerm_kubernetes_cluster.aks_cluster.identity[0].principal_id
  scope                            = azurerm_virtual_network.aks-vnet.id
  role_definition_name             = "Contributor"
  skip_service_principal_aad_check = true
  depends_on = [azurerm_kubernetes_cluster.aks_cluster, azurerm_virtual_network.aks-vnet]
}

