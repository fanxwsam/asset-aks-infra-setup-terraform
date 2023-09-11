data "azuread_service_principal" "aks_sp_cluster_issuer" {
  display_name = var.aks_cluster_issuer_sp_name
}

data "azuread_application" "aks_app_cluster_issuer" {
  display_name = var.aks_cluster_issuer_sp_name
}

# generate the cluster issuer file through the template
# render the parameters in the template
# resource "local_file" "cluster_issuer_template" {
#     for_each = toset([
#         for file in fileset(path.module, "${path.module}/01-cert-manager/template/**"):
#             file //if length(regexall(".*app-template.*", file)) == 0 # Ignore paths with "app-template"
#     ])

#     //for_each = fileset(path.module, "${path.module}/01-cert-manager/template/*")

#     content = templatefile(each.key, {
#           clientID = data.azuread_service_principal.aks_sp_cluster_issuer.application_id
#           subscriptionID = data.azurerm_client_config.current.subscription_id
#           tenantID = data.azurerm_client_config.current.tenant_id
#           resourceGroupName  = var.az_dns_zone_rg_name
#           hostedZoneName = var.az_dns_zone_name          
#     })
    
#     filename = replace("${path.module}/${each.key}", "template", "rendered")
# }

# create namespace of cert manager
resource "kubernetes_namespace" "cert_manager" { 
  metadata {
    name        = var.cert_manager_namespace
  }
}

# install cert manager through helm
resource "helm_release" "cert_manager" {
    name             = var.cert_manager_release_name
    chart            = var.cert_manager_chart
    namespace        = var.cert_manager_namespace
    repository       = var.cert_manager_repository
    version          = var.cert_manager_chart_version  
    create_namespace = var.create_namespace

    values = [ file("${path.module}/01-cert-manager/values.yml")]

    set {
        name  = "startupapicheck.timeout"
        value = "5m"
    }

    set {
        name  = "installCRDs"
        value = var.cert_manager_crd_flag
    }

    set {
        name  = "namespaceLabels.cert-manager.cert-manager.io/disable-validation"
        value = true
    }

    // depends_on = [kubernetes_namespace.cert_manager, local_file.cluster_issuer_template, local_file.external_dns_template]
    depends_on = [kubernetes_namespace.cert_manager]
}

# create a new password for the application cluster issuer 
# the applicate was created after the cluster created, it is used for cluster issuer access configuration
resource "azuread_application_password" "create_sp_cluter_issuer_password" {
  application_object_id = data.azuread_application.aks_app_cluster_issuer.object_id  
  end_date              = "2030-01-01T01:00:00Z"
}

# create secrete to handle the application password 
resource "kubernetes_secret" "azuredns_config" {
  metadata {
    name = "azuredns-config"
    namespace = "cert-manager"
  }

  data = {
    "client-secret" = nonsensitive(azuread_application_password.create_sp_cluter_issuer_password.value)
  }
}

# resource "kubernetes_manifest" "cluster_issuer" {  
#   manifest = yamldecode(file("./01-cert-manager/rendered/cluster-issuer-rendered.yml"))
  
#   depends_on = [helm_release.cert_manager, azuread_application_password.create_sp_cluter_issuer_password,kubernetes_secret.azuredns_config, local_file.cluster_issuer_template]
# }

# create cluster issuer with proper privillege (controlled through application registered in Azure)
# resource "kubernetes_manifest" "cluster_issuer" {
#   for_each = fileset("${path.module}/01-cert-manager/rendered/", "*.yml")
#   manifest = yamldecode(file("${path.module}/01-cert-manager/rendered/${each.value}"))
#   depends_on = [helm_release.cert_manager, azuread_application_password.create_sp_cluter_issuer_password, kubernetes_secret.azuredns_config, local_file.cluster_issuer_template]
# }



data "template_file" "cluster_issuer_template" {
  

  template = "${file("${path.module}/01-cert-manager/template/cluster-issuer-template.yml")}"

  vars = {
          clientID = data.azuread_service_principal.aks_sp_cluster_issuer.application_id
          subscriptionID = data.azurerm_client_config.current.subscription_id
          tenantID = data.azurerm_client_config.current.tenant_id
          resourceGroupName  = var.az_dns_zone_rg_name
          hostedZoneName = var.az_dns_zone_name  
  }
}

# resource "kubernetes_manifest" "cluster_issuer" {
#   depends_on = [helm_release.cert_manager, azuread_application_password.create_sp_cluter_issuer_password,kubernetes_secret.azuredns_config]

#   // manifest = yamldecode(file(template_file.cluster_issuer_template.rendered))
#   manifest = yamldecode(data.template_file.cluster_issuer_template.rendered)
#   //depends_on = [helm_release.cert_manager, azuread_application_password.create_sp_cluter_issuer_password,kubernetes_secret.azuredns_config]
  
# }

resource "kubectl_manifest" "cluster_issuer" {    
    yaml_body = data.template_file.cluster_issuer_template.rendered    
    depends_on = [helm_release.cert_manager, azuread_application_password.create_sp_cluter_issuer_password,kubernetes_secret.azuredns_config]
}

