resource "kubernetes_namespace" "opentelemetry" {
  metadata {
    name = "otel"
  }
}
