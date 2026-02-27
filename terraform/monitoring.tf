# ───────────────────────────────────────────
# kube-prometheus-stack (Prometheus + Grafana + AlertManager)
# Namespace defined in namespaces.tf
# ───────────────────────────────────────────

resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.kube_prometheus_stack_version
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  timeout    = 600

  # --- Grafana ---
  set {
    name  = "grafana.enabled"
    value = "true"
  }

  set {
    name  = "grafana.adminUser"
    value = var.grafana_admin_user
  }

  set_sensitive {
    name  = "grafana.adminPassword"
    value = var.grafana_admin_password
  }

  # Expose Grafana via LoadBalancer (доступ ззовні)
  set {
    name  = "grafana.service.type"
    value = var.grafana_service_type
  }

  # --- Prometheus ---
  set {
    name  = "prometheus.prometheusSpec.retention"
    value = var.prometheus_retention
  }

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName"
    value = "gp3"
  }

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage"
    value = var.prometheus_storage_size
  }

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.accessModes[0]"
    value = "ReadWriteOnce"
  }

  # --- Sidecar: підхоплює ConfigMap-дашборди з анотацією grafana_folder ---
  set {
    name  = "grafana.sidecar.dashboards.enabled"
    value = "true"
  }

  set {
    name  = "grafana.sidecar.dashboards.label"
    value = "grafana_dashboard"
  }

  set {
    name  = "grafana.sidecar.dashboards.folderAnnotation"
    value = "grafana_folder"
  }

  # --- AlertManager ---
  set {
    name  = "alertmanager.enabled"
    value = "true"
  }

  # --- Node Exporter & kube-state-metrics (увімкнено за замовчуванням) ---
  set {
    name  = "nodeExporter.enabled"
    value = "true"
  }

  set {
    name  = "kubeStateMetrics.enabled"
    value = "true"
  }

  depends_on = [module.eks, kubernetes_storage_class.gp3]
}

# ───────────────────────────────────────────
# Grafana dashboards — provisioned via sidecar
# Файли з grafana-dashboards/*.json → папка "int20h" в Grafana
# ───────────────────────────────────────────

resource "kubernetes_config_map" "grafana_dashboards" {
  metadata {
    name      = "grafana-dashboards-int20h"
    namespace = kubernetes_namespace.monitoring.metadata[0].name

    labels = {
      grafana_dashboard = "1"
    }

    annotations = {
      grafana_folder = var.grafana_dashboard_folder
    }
  }

  data = {
    for f in fileset("${path.module}/../grafana-dashboards", "*.json") :
    f => file("${path.module}/../grafana-dashboards/${f}")
  }

  depends_on = [helm_release.kube_prometheus_stack]
}
