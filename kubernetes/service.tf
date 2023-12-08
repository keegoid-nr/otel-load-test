data "kubernetes_service" "otel_collector" {
  metadata {
    name      = kubernetes_daemonset.otel_collector.metadata[0].name
    namespace = kubernetes_namespace.opentelemetry.metadata[0].name
  }
}
