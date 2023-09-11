data "kubectl_file_documents" "docs_metrics_dashboard_components" {
    content = file("${path.module}/04-metrics-dashboard/components.yml")
}

data "kubectl_file_documents" "docs_metrics_dashboard_recommended" {
    content = file("${path.module}/04-metrics-dashboard/recommended.yml")
}

data "kubectl_file_documents" "docs_metrics_dashboard_aks_admin_service_account" {
    content = file("${path.module}/04-metrics-dashboard/aks-admin-service-account.yml")
}

data "kubectl_file_documents" "docs_metrics_dashboard_aks_admin_service_account_token" {
    content = file("${path.module}/04-metrics-dashboard/aks-admin-service-account-token.yml")
}

# apply manifest file 'components'
resource "kubectl_manifest" "metrics_dashboard_components" {
    for_each  = data.kubectl_file_documents.docs_metrics_dashboard_components.manifests
    yaml_body = each.value
    
    lifecycle {
      ignore_changes = [yaml_incluster]
    } 
}

resource "kubernetes_namespace" "kubernetes_dashboard" { 
  metadata {
    name = "kubernetes-dashboard"
  }
}

# apply manifest file 'recommended'
resource "kubectl_manifest" "metrics_dashboard_recommended" {
    for_each  = data.kubectl_file_documents.docs_metrics_dashboard_recommended.manifests
    yaml_body = each.value

    lifecycle {
      ignore_changes = [yaml_incluster]
    } 

    depends_on = [kubectl_manifest.metrics_dashboard_components, kubernetes_namespace.kubernetes_dashboard]
}

resource "kubectl_manifest" "metrics_dashboard_aks_admin_service_account" {
    for_each  = data.kubectl_file_documents.docs_metrics_dashboard_aks_admin_service_account.manifests
    yaml_body = each.value
    depends_on = [kubectl_manifest.metrics_dashboard_recommended]
}

# through this configuration, login with token enabled
# Get the token: kubectl describe secret aks-admin-token -n kube-system
resource "kubectl_manifest" "metrics_dashboard_aks_admin_service_account_token" {
    for_each  = data.kubectl_file_documents.docs_metrics_dashboard_aks_admin_service_account_token.manifests
    yaml_body = each.value
    depends_on = [kubectl_manifest.metrics_dashboard_aks_admin_service_account]
}