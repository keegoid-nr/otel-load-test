data "kubernetes_service" "otel_collector" {
  metadata {
    name      = kubernetes_daemonset.otel_collector.metadata[0].name
    namespace = kubernetes_namespace.otel.metadata[0].name
  }

  spec {
    selector = {
      app = kubernetes_daemonset.otel_collector.metadata[0].name
    }

    # port {
    #   port        = 1777  // pprof extension | https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/extension/pprofextension/README.md
    #   target_port = 1777
    # }

    # port {
    #   port        = 8888  // Prometheus metrics exposed by the collector
    #   target_port = 8888
    # }

    # port {
    #   port        = 8889  // Prometheus exporter metrics
    #   target_port = 8889
    # }

    port {
      port        = 13133  // health_check extension | https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/extension/healthcheckextension
      target_port = 13133
    }

    port {
      port        = 4317  // OTLP gRPC receiver
      target_port = 4317
    }

    port {
      port        = 4318  // OTLP HTTP receiver
      target_port = 4318
    }

    port {
      port        = 25679  // zpages extension | https://github.com/open-telemetry/opentelemetry-collector/blob/main/extension/zpagesextension/README.md
      target_port = 25679
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "otel_load_test" {
  metadata {
    name = var.repository_name
    namespace = kubernetes_namespace.otel.metadata[0].name
  }

  spec {
    selector = {
      app = var.repository_name
    }

    type = "ClusterIP"
  }
}
