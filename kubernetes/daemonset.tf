resource "kubernetes_daemonset" "otel_collector" {
  metadata {
    name = "otel-collector"
    namespace = kubernetes_namespace.otel.metadata[0].name
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
          image = "otel/opentelemetry-collector-contrib:latest"
          name  = "otel-collector"

          env {
            name  = "LOG_EXPORTER_LOG_VERBOSITY"
            value = var.LOG_EXPORTER_VERBOSITY
          }

          env {
            name  = "NEW_RELIC_OTLP_ENDPOINT"
            value = var.NEW_RELIC_OTLP_ENDPOINT
          }

          env {
            name  = "NEW_RELIC_API_KEY"
            value = var.NEW_RELIC_API_KEY
          }

          # args = [
          #   "--config=/etc/otel/config/otel-config.yaml",
          # ]

          command = ["--config=/otel-config.yaml"]

          # port {
          #   container_port = 4317   // gRPC
          # }
          # port {
          #   container_port = 13133  // Health check
          # }

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
            # mount_path = "/etc/otel/config"
            mount_path = "/otel-config.yaml"
            name       = "config-volume"
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
    name      = var.repository_name
    namespace = kubernetes_namespace.otel.metadata[0].name
  }

  spec {
    selector {
      match_labels = {
        app = var.repository_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.repository_name
        }
      }

      spec {
        container {
          image = "${var.registry_name}/${var.repository_name}:latest"
          name  = var.repository_name

          env {
            name  = "OTEL_SERVICE_NAME"
            value = var.repository_name
          }

          env {
            name  = "OTEL_LOGS_EXPORTER"
            value = "debug"
          }

          env {
            name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
            value = "http://otel-collector:4317"
          }

          env {
            name  = "OTEL_EXPERIMENTAL_RESOURCE_DISABLED_KEYS"
            value = "process.command_line,process.command_args"
          }

          env {
            name  = "OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE"
            value = "delta"
          }

          env {
            name  = "OTEL_ATTRIBUTE_VALUE_LENGTH_LIMIT"
            value = 4095
          }
        }
      }
    }
  }
}
