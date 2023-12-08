resource "kubernetes_config_map" "otel_config" {
  metadata {
    name = "otel-config"
    namespace = kubernetes_namespace.opentelemetry.metadata[0].name
  }


  data = {
    "otel-config.yaml" = <<EOT
extensions:
health_check:
# pprof:
#   endpoint: :1777
zpages:
  endpoint: :55679
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: "0.0.0.0:4317"
      http:
        endpoint: "0.0.0.0:4318"
processors:
  batch:
    timeout: 5s
    # send_batch_size: 100
    # send_batch_max_size: 200
exporters:
  debug:
    verbosity: "${var.log_exporter_log_verbosity}"
  otlp:
    endpoint: "${var.NEW_RELIC_OTLP_ENDPOINT}"
    headers:
      "api-key": "${var.NEW_RELIC_API_KEY}"
    compression: gzip
    retry_on_failure:
      enabled: true
      initial_interval: 1s
      max_interval: 10s
      max_elapsed_time: 120s
    sending_queue:
      enabled: true
      num_consumers: 10
      queue_size: 50 # num_seconds * requests_per_second / requests_per_batch
service:
  extensions: [zpages, health_check]
  pipelines:
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug, otlp]
EOT
  }
}
