resource "kubernetes_namespace" "ingress-nginx" { 
  metadata {
    name        = var.ingress_nginx_namespace
  }
}

resource "kubernetes_namespace" "ingress-nginx-internal" { 
  metadata {
    name        = var.ingress_nginx_namespace_internal
  }
}

data "azurerm_public_ip" "aks_cluster_ingress_public_ip" {
  name                = "${var.aks_cluster_name}_ingress_public_ip"
  resource_group_name = var.aks_cluster_node_rg_name  
}

# create pulic ingress-nginx through helm
resource "helm_release" "ingress-nginx" {
    name             = var.ingress_nginx_release_name
    chart            = var.ingress_nginx_chart
    namespace        = var.ingress_nginx_namespace
    repository       = var.ingress_nginx_repository
    version          = var.ingress_nginx_chart_version 

    create_namespace = var.create_namespace

    values = [ file("${path.module}/03-ingress-nginx/values.yml")]

    set {
        name  = "controller.replicaCount"
        value = 2
    }
    
    set {
        name  = "controller.nodeSelector.app"
        value = "system-apps"
    }

    set {
        name  = "controller.admissionWebhooks.patch.nodeSelector.app"
        value = "system-apps"
    }

    set {
        name  = "controller.admissionWebhooks.patch.image.digest"
        value = ""
    }

    set {
        name  = "defaultBackend.nodeSelector.app"
        value = "system-apps"
    }

    set {
        name  = "controller.extraArgs.enable-ssl-passthrough"
        value = ""
    }

    set {
        name  = "controller.service.externalTrafficPolicy"
        value = "Local"
    }

    set {
        name  = "controller.service.loadBalancerIP"
        value = data.azurerm_public_ip.aks_cluster_ingress_public_ip.ip_address
    }

    set {
        name  = "prometheus.create"
        value = true
    }

    depends_on = [kubernetes_namespace.ingress-nginx]
}


# Install Internal Ingress Nginx
resource "helm_release" "ingress-nginx-internal" {
    name             = var.ingress_nginx_release_name_internal
    chart            = var.ingress_nginx_chart
    namespace        = var.ingress_nginx_namespace_internal
    repository       = var.ingress_nginx_repository
    version          = var.ingress_nginx_chart_version 
    create_namespace = var.create_namespace

    values = [ file("${path.module}/03-ingress-nginx/values.yml")]

    set {
        name  = "controller.replicaCount"
        value = 2
    }
    
    set {
        name  = "controller.nodeSelector.app"
        value = "system-apps"
    }

    set {
        name  = "controller.admissionWebhooks.patch.nodeSelector.app"
        value = "system-apps"
    }

    set {
        name  = "controller.admissionWebhooks.patch.image.digest"
        value = ""
    }

    set {
        name  = "defaultBackend.nodeSelector.app"
        value = "system-apps"
    }

    set {
        name  = "controller.extraArgs.enable-ssl-passthrough"
        value = ""
    }

    set {
        name  = "controller.service.externalTrafficPolicy"
        value = "Local"
    }

    set {
        name  = "controller.ingressClassResource.name"
        value = var.ingress_nginx_classname_internal
    }

    set {
        name  = "controller.ingressClassResource.controllerValue"
        value = "k8s.io/internal-ingress-nginx"
    }

    set {
        name  = "controller.service.public"
        value = false
    }    

    set {
        name  = "controller.publishService.enabled"
        value = true
    }

    set {
        name  = "controller.service.annotations.'service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal'"
        value = "true"
    }

    set {
        name  = "controller.service.annotations.'service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal-subnet'"
        value = "aks-${var.environment}-subnet-api"
    }  

    set {
        name  = "prometheus.create"
        value = true
    }

    depends_on = [kubernetes_namespace.ingress-nginx-internal]
}