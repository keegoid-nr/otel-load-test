resource "kubernetes_daemonset" "otel_collector" {
  metadata {
    name = "otel-collector"
    namespace = kubernetes_namespace.opentelemetry.metadata[0].name
    labels = {
      app = "otel-collector"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "otel-collector"
      }
    }

    template {
      metadata {
        labels = {
          app = "otel-collector"
        }
      }

      spec {
        container {
          name  = "collector"
          image = "otel/opentelemetry-collector:latest"

          args = [
            "--config=/etc/otel/config/otel-config.yaml",
          ]

          env {
            name  = "LOG_EXPORTER_LOG_VERBOSITY"
            value = var.log_exporter_log_verbosity
          }

          port {
            container_port = 4317   // gRPC
          }
          port {
            container_port = 13133  // Health check
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "128Mi"
            }
          }

          volume_mount {
            name       = "config-volume"
            mount_path = "/etc/otel/config"
            read_only  = true
          }
        }

        volume {
          name = "config-volume"

          config_map {
            name = kubernetes_config_map.otel_config.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_daemonset" "otel_load_test" {
  metadata {
    name      = var.container_repository
    namespace = kubernetes_namespace.opentelemetry.metadata[0].name
  }

  spec {
    selector {
      match_labels = {
        app = var.container_repository
      }
    }

    template {
      metadata {
        labels = {
          app = var.container_repository
        }
      }

      spec {
        container {
          name  = var.container_repository
          image = "${var.container_registry}/${var.container_repository}:latest"

          env {
            name  = "OTEL_COLLECTOR_ADDRESS"
            value = "${data.kubernetes_service.otel_collector.metadata[0].name}.${data.kubernetes_service.otel_collector.metadata[0].namespace}:4317"
          }

          port {
            container_port = 4317
          }
        }
      }
    }
  }
}
