resource "kubernetes_namespace" "monitoring" {
    metadata {
      name = var.prometheus_namespace
    }
}

# config the grafana user name and password
resource "kubernetes_secret" "grafana_credentials_secret" {
  metadata {
    name = "grafana-credentials-secret"
    namespace = var.prometheus_namespace
  }

  data = {
    "admin-user" = var.aks_grafana_admin_user
    "admin-password" = var.aks_grafana_admin_password
  }

  depends_on = [kubernetes_namespace.monitoring]
}

# install prometheus using helm chart
resource "helm_release" "prometheus" {
    name             = var.prometheus_release_name
    chart            = var.prometheus_chart
    namespace        = var.prometheus_namespace
    repository       = var.prometheus_repository
    version          = var.prometheus_chart_version  
    create_namespace = var.create_namespace

    values = [ file("${path.module}/05-prometheus-grafana/02-prometheus-grafana-values.yml")]

    set {
        name  = "prometheus.service.nodePort"
        value = 30000
    }

    set {
        name  = "prometheus.service.type"
        value = "NodePort"
    }

    set {
        name  = "kubeEtcd.enabled"
        value = false
    }

    set {
        name  = "kubeControllerManager.enabled"
        value = false
    } 

    depends_on = [kubernetes_secret.grafana_credentials_secret, kubectl_manifest.storage_cstor]
}

data "kubectl_file_documents" "docs_cstor_prometheus_alerts" {
    content = file("${path.module}/05-prometheus-grafana/03-cstor-prometheus-alerts.yml")
}

# config the disk alert rules
resource "kubectl_manifest" "cstor_prometheus_alerts" {
  for_each  = data.kubectl_file_documents.docs_cstor_prometheus_alerts.manifests
  yaml_body = each.value
  depends_on = [helm_release.prometheus] 
}



