extensions:
 health_check:
  pprof:
    endpoint: :1777
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
    verbosity: ${LOG_EXPORTER_VERBOSITY}
  otlp:
    endpoint: ${NEW_RELIC_OTLP_ENDPOINT}
    headers:
      "api-key": ${NEW_RELIC_API_KEY}
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
  extensions: [pprof, zpages, health_check]
  pipelines:
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug, otlp]
