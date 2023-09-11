/*
## Step-02: Create External DNS
- External-DNS needs permissions to Azure DNS to modify (Add, Update, Delete DNS Record Sets)
- There are two ways in Azure to provide permissions to External-DNS pod 
  - Using Azure Service Principal
  - Using Azure Managed Service Identity (MSI)
- We are going to use `MSI` for providing necessary permissions here which is latest and greatest in Azure. 
*/

data "azurerm_user_assigned_identity" "managed_identity_agent_pool" {
  name = "${var.aks_cluster_name}-agentpool"
  
  resource_group_name = var.aks_cluster_node_rg_name
}

# azure_config_file for public external dns
resource "kubernetes_secret" "azure_config_file" {
  metadata {
    name = "azure-config-file"
    namespace = "kube-system"
  }

  data = {
    "azure.json" = jsonencode({
      "tenantId": data.azurerm_client_config.current.tenant_id,
      "subscriptionId": data.azurerm_client_config.current.subscription_id,
      "resourceGroup": var.az_dns_zone_rg_name,
      "useManagedIdentityExtension": true,
      "userAssignedIdentityID": data.azurerm_user_assigned_identity.managed_identity_agent_pool.client_id
    })
  }

  type = "Opaque"
}

# azure_config_file for private external dns
resource "kubernetes_secret" "azure_config_file_private" {
  metadata {
    name = "azure-config-file-private"
    namespace = "kube-system"
  }

  data = {
    "azure.json" = jsonencode({
      "tenantId": data.azurerm_client_config.current.tenant_id,
      "subscriptionId": data.azurerm_client_config.current.subscription_id,
      "resourceGroup": var.az_private_dns_zone_rg_name,
      "useManagedIdentityExtension": true,  
      "userAssignedIdentityID": data.azurerm_user_assigned_identity.managed_identity_agent_pool.client_id
    })
  }
  
  type = "Opaque"
}

# # generate the external dns manifest files
# # render the parameters
# resource "local_file" "external_dns_template" {
#     # for_each = toset([
#     #     for file in fileset(path.module, "${path.module}/02-external-dns/templates/**"):
#     #         file if length(regexall(".*app-template.*", file)) == 0 # Ignore paths with "app-template"
#     # ])

#     for_each = fileset(path.module, "${path.module}/02-external-dns/templates/**")

#     content = templatefile(each.key, {
#         txt-owner-id = var.aks_cluster_name
#         domain-filter =  var.az_dns_zone_name
#         azure-resource-group-public = var.az_dns_zone_rg_name
#         azure-resource-group-private = var.az_private_dns_zone_rg_name  
#     })
    
#     filename = replace("${path.module}/${each.key}", "template", "rendered")
# }


# # apply the External DNS manifest files to create public and private External DNS components
# resource "kubernetes_manifest" "external_dns" {
#   for_each = fileset("${path.module}/02-external-dns/rendereds/", "*.yml")
#   manifest = yamldecode(file("${path.module}/02-external-dns/rendereds/${each.value}"))
#   depends_on = [helm_release.cert_manager, kubectl_manifest.external_dns_role, kubernetes_manifest.cluster_issuer]
# }



data "kubectl_file_documents" "docs_external_dns_role" {
    content = file("${path.module}/02-external-dns/external-dns-role.yml")
}

# initialize the External DNS privilege
# public External DNS has the same privilege configuration as the private External DNS in cluster role level
resource "kubectl_manifest" "external_dns_role" {
    for_each  = data.kubectl_file_documents.docs_external_dns_role.manifests
    yaml_body = each.value
}


data "template_file" "external_dns_template_public" {
  

  template = "${file("${path.module}/02-external-dns/templates/external-dns-public-template.yml")}"

  vars = {
          txt-owner-id = var.aks_cluster_name
          domain-filter =  var.az_dns_zone_name
          azure-resource-group-public = var.az_dns_zone_rg_name
          azure-resource-group-private = var.az_private_dns_zone_rg_name  
  }
}

data "template_file" "external_dns_template_private" {
  

  template = "${file("${path.module}/02-external-dns/templates/external-dns-private-template.yml")}"

  vars = {
          txt-owner-id = var.aks_cluster_name
          domain-filter =  var.az_dns_zone_name
          azure-resource-group-public = var.az_dns_zone_rg_name
          azure-resource-group-private = var.az_private_dns_zone_rg_name  
  }
}

# resource "kubernetes_manifest" "external_dns_public" {
  
#   // manifest = yamldecode(file(template_file.cluster_issuer_template.rendered))
#   manifest = yamldecode(data.template_file.external_dns_template_public.rendered)
#   //depends_on = [helm_release.cert_manager, kubectl_manifest.external_dns_role, kubernetes_manifest.cluster_issuer]
#   depends_on = [helm_release.cert_manager, kubectl_manifest.external_dns_role]
# }

resource "kubectl_manifest" "external_dns_public" {    
    yaml_body = data.template_file.external_dns_template_public.rendered
    depends_on = [helm_release.cert_manager, kubectl_manifest.external_dns_role]
}

# resource "kubernetes_manifest" "external_dns_private" {
#   manifest = yamldecode(data.template_file.external_dns_template_private.rendered)
#   //depends_on = [helm_release.cert_manager, kubectl_manifest.external_dns_role, kubernetes_manifest.cluster_issuer]
#   depends_on = [helm_release.cert_manager, kubectl_manifest.external_dns_role]
# }

resource "kubectl_manifest" "external_dns_private" {    
    yaml_body = data.template_file.external_dns_template_private.rendered
    depends_on = [helm_release.cert_manager, kubectl_manifest.external_dns_role]
}