# data "azurerm_dns_zone" "dns_zone_az1_asset" {
#   name                = "kubedev.link"
#   resource_group_name = "dns-zone"
# }

# data "azurerm_dns_zone" "dns_zone_az1_asset" {
#   name                = var.az_dns_zone_name
#   resource_group_name = var.az_dns_zone_resource_group_name
# }

data "azurerm_client_config" "current" {}

output "subscription_id"{
    value = data.azurerm_client_config.current.subscription_id
}

output "tenant_id"{
    value = data.azurerm_client_config.current.tenant_id
}


output "az_cluster_issuer_sp_app_id"{
    value = data.azuread_service_principal.aks_sp_cluster_issuer.application_id
}

output "aks_sp_cluster_issuer_password_non_sensitive" {    
    value = nonsensitive(azuread_application_password.create_sp_cluter_issuer_password.value)
}

output "aks_cluster_ingress_public_ip" {
    value = data.azurerm_public_ip.aks_cluster_ingress_public_ip.ip_address
}