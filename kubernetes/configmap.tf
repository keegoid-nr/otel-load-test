data "template_file" "otel_config" {
  template = file("${path.module}/otel-config-${var.OTEL_CONFIG_COMPLEXITY}.yaml.tpl")

  vars = {
    LOG_EXPORTER_VERBOSITY = var.LOG_EXPORTER_VERBOSITY
    NEW_RELIC_OTLP_ENDPOINT = var.NEW_RELIC_OTLP_ENDPOINT
    NEW_RELIC_API_KEY = var.NEW_RELIC_API_KEY
  }
}

resource "kubernetes_config_map" "otel_config" {
  metadata {
    name = "otel-config"
    namespace = kubernetes_namespace.otel.metadata[0].name
  }

  data = {
    "otel-config.yaml" = data.template_file.otel_config.rendered
  }
}

#   data = {
#     "otel-config.yaml" = <<EOT
# extensions:
# health_check:
# # pprof:
# #   endpoint: :1777
# zpages:
#   endpoint: :25679
# receivers:
#   otlp:
#     protocols:
#       grpc:
#         endpoint: "0.0.0.0:4317"
#       http:
#         endpoint: "0.0.0.0:4318"
# processors:
#   batch:
#     timeout: 5s
#     # send_batch_size: 100
#     # send_batch_max_size: 200
# exporters:
#   debug:
#     verbosity: "${var.LOG_EXPORTER_VERBOSITY}"
#   otlp:
#     endpoint: "${var.NEW_RELIC_OTLP_ENDPOINT}"
#     headers:
#       "api-key": "${var.NEW_RELIC_API_KEY}"
#     compression: gzip
#     retry_on_failure:
#       enabled: true
#       initial_interval: 1s
#       max_interval: 10s
#       max_elapsed_time: 120s
#     sending_queue:
#       enabled: true
#       num_consumers: 10
#       queue_size: 50 # num_seconds * requests_per_second / requests_per_batch
# service:
#   extensions: [zpages, health_check]
#   pipelines:
#     metrics:
#       receivers: [otlp]
#       processors: [batch]
#       exporters: [debug, otlp]
# EOT
#   }
# }
