#########################   Linkerd   ###########################
data "template_file" "ingress_linkerd_web_certificate" {
  template = "${file("${path.module}/07-components-ingress/01-ingress-linkerd-web-certificate.yml")}"

  vars = {
          host = var.linkerd_viz_host
  }
}

resource "kubectl_manifest" "ingress_linkerd_web_certificate" {
    yaml_body = data.template_file.ingress_linkerd_web_certificate.rendered

    depends_on = [ helm_release.cert_manager, kubectl_manifest.cluster_issuer,helm_release.ingress-nginx, helm_release.ingress-nginx-internal, kubectl_manifest.metrics_dashboard_recommended, kubectl_manifest.metrics_dashboard_components, helm_release.stackgres]
}

data "kubectl_file_documents" "ingress_linkerd_web_secret" {
    content = file("${path.module}/07-components-ingress/01-linkerd-viz-console-secret.yml")
}

resource "kubectl_manifest" "ingress_linkerd_web_secret" {
    for_each  = data.kubectl_file_documents.ingress_linkerd_web_secret.manifests
    yaml_body = each.value
    depends_on = [kubectl_manifest.ingress_linkerd_web_certificate]

}

data "template_file" "ingress_linkerd_web_host_public" {
  template = "${file("${path.module}/07-components-ingress/01-ingress-linkerd-web-public.yml")}"

  vars = {
          host = var.linkerd_viz_host
  }
}

resource "kubectl_manifest" "ingress_linkerd_web_host_public" {
    yaml_body = data.template_file.ingress_linkerd_web_host_public.rendered
    depends_on = [kubectl_manifest.ingress_linkerd_web_secret]
}


######################### Dashboard ###########################
data "template_file" "ingress_dashboard_certificate" {
  template = "${file("${path.module}/07-components-ingress/02-dashboard-ingress-certificate.yml")}"

  vars = {
          host = var.metrics_dashboard_host
  }
}

resource "kubectl_manifest" "ingress_dashboard_certificate" {
    yaml_body = data.template_file.ingress_dashboard_certificate.rendered
    depends_on = [kubectl_manifest.ingress_linkerd_web_host_public]
}

data "template_file" "ingress_dashboard_host_public" {
  template = "${file("${path.module}/07-components-ingress/02-dashboard-ingress-public.yml")}"

  vars = {
          host = var.metrics_dashboard_host
  }
}

resource "kubectl_manifest" "ingress_dashboard_host" {
    yaml_body = data.template_file.ingress_dashboard_host_public.rendered
    depends_on = [kubectl_manifest.ingress_linkerd_web_host_public, kubectl_manifest.ingress_dashboard_certificate]
}

########################## Grafana ##########################
data "template_file" "ingress_grafana_certificate" {
  template = "${file("${path.module}/07-components-ingress/03-grafana-service-ingress-certificate.yml")}"

  vars = {
          host = var.grafana_host
  }
}

resource "kubectl_manifest" "ingress_grafana_certificate" {
    yaml_body = data.template_file.ingress_grafana_certificate.rendered
    depends_on = [kubectl_manifest.ingress_linkerd_web_host_public]
}

data "template_file" "ingress_grafana_host_public" {
  template = "${file("${path.module}/07-components-ingress/03-grafana-service-ingress-public.yml")}"

  vars = {
          host = var.grafana_host
  }
}

resource "kubectl_manifest" "ingress_grafana_host" {
    yaml_body = data.template_file.ingress_grafana_host_public.rendered
    depends_on = [kubectl_manifest.ingress_linkerd_web_host_public, kubectl_manifest.ingress_grafana_certificate]
}

######################### Prometheus ###########################
data "template_file" "ingress_prometheus_certificate" {
  template = "${file("${path.module}/07-components-ingress/04-prometheus-service-ingress-certificate.yml")}"

  vars = {
          host = var.prometheus_host
  }
}

resource "kubectl_manifest" "ingress_prometheus_certificate" {
    yaml_body = data.template_file.ingress_prometheus_certificate.rendered
    depends_on = [kubectl_manifest.ingress_linkerd_web_host_public]
}

data "template_file" "ingress_prometheus_host_private" {
  template = "${file("${path.module}/07-components-ingress/04-prometheus-service-ingress-private.yml")}"

  vars = {
          host = var.prometheus_host
  }
}

resource "kubectl_manifest" "ingress_prometheus_host" {
    yaml_body = data.template_file.ingress_prometheus_host_private.rendered    
    depends_on = [kubectl_manifest.ingress_linkerd_web_host_public, kubectl_manifest.ingress_prometheus_certificate]
}


######################### Stackgres ###########################
data "template_file" "ingress_stackgres_certificate" {
  template = "${file("${path.module}/07-components-ingress/05-stackgres-ui-service-ingress-certificate.yml")}"

  vars = {
          host = var.stackgres_host
  }
}

resource "kubectl_manifest" "ingress_stackgres_certificate" {
    yaml_body = data.template_file.ingress_stackgres_certificate.rendered
    depends_on = [kubectl_manifest.ingress_linkerd_web_host_public] 
}

data "template_file" "ingress_stackgres_host_public" {
  template = "${file("${path.module}/07-components-ingress/05-stackgres-ui-service-ingress-public.yml")}"

  vars = {
          host = var.stackgres_host
  }
}

resource "kubectl_manifest" "ingress_stackgres_host" {
    yaml_body = data.template_file.ingress_stackgres_host_public.rendered
    depends_on = [kubectl_manifest.ingress_linkerd_web_host_public, kubectl_manifest.ingress_stackgres_certificate] 
}