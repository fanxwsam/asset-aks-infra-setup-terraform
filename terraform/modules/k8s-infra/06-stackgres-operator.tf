resource "kubernetes_namespace" "stackgres" { 
  metadata {
    name        = var.stackgres_namespace
    annotations = {
      name = "linkerd.io/inject=enabled"
    }
  }
}

# install stackgres using helm chart
resource "helm_release" "stackgres" {
    name             = var.stackgres_release_name
    chart            = var.stackgres_chart
    namespace        = var.stackgres_namespace
    repository       = var.stackgres_repository
    version          = var.stackgres_chart_version  
    create_namespace = var.create_namespace

    set {
        name  = "grafana.autoEmbed"
        value = true
    }

    set {
        name  = "grafana.webHost"
        value = "prometheus-grafana.monitoring"
    }    

    set {
        name  = "grafana.secretNamespace"
        value = "monitoring"
    }

    set {
        name  = "grafana.secretName"
        value = "grafana-credentials-secret"
    }

    set {
        name  = "grafana.secretUserKey"
        value = "admin-user"
    }

    set {
        name  = "grafana.secretPasswordKey"
        value = "admin-password"
    }

    set {
        name  = "adminui.service.type"
        value = "ClusterIP"
    }

    set {
        name  = "cluster.pods.persistentVolume.storageclass"
        value = "cstor-mirror"
    }

    set {
        name  = "cluster.pods.persistentVolume.size"
        value = "5Gi"
    }

    set {
        name  = "cluster.pods.scheduling.nodeSelector.app"
        value = "dbcluster-apps"
    }

    set {
        name  = "jobs.nodeSelector.app"
        value = "system-apps"
    }                            

    set {
        name  = "operator.nodeSelector.app"
        value = "system-apps"
    }            

        set {
        name  = "restapi.nodeSelector.app"
        value = "system-apps"
    }

    depends_on = [kubernetes_namespace.stackgres, kubectl_manifest.storage_cstor, helm_release.prometheus,kubectl_manifest.metrics_dashboard_recommended]
}


