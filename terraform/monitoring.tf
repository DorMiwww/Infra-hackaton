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

  # Datasource — явно вказуємо Prometheus URL
  set {
    name  = "grafana.additionalDataSources[0].name"
    value = "Prometheus"
  }

  set {
    name  = "grafana.additionalDataSources[0].type"
    value = "prometheus"
  }

  set {
    name  = "grafana.additionalDataSources[0].url"
    value = "http://kube-prometheus-stack-prometheus.monitoring.svc.cluster.local:9090"
  }

  set {
    name  = "grafana.additionalDataSources[0].access"
    value = "proxy"
  }

  set {
    name  = "grafana.additionalDataSources[0].isDefault"
    value = "true"
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
