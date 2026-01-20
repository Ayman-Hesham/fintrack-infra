resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  version    = "2.9.11"
  namespace  = kubernetes_namespace.observability.metadata[0].name

  values = [yamlencode({
    loki = {
      enabled = true
      persistence = {
        enabled = true
        size    = "5Gi" # Minimal storage
      }
    }
    promtail = {
      enabled = false
    }
    fluent-bit = {
      enabled = true
    }
  })]

  depends_on = [kubernetes_namespace.observability]
}
