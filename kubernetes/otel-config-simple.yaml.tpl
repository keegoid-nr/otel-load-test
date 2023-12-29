exporters:
  debug:
    verbosity: basic
  otlp:
    endpoint: "https://otlp.nr-data.net:4317"
    headers:
      "api-key": ${NEW_RELIC_API_KEY}
    compression: gzip
    # retry_on_failure:
    #   enabled: true
    #   initial_interval: 1s
    #   max_interval: 10s
    #   max_elapsed_time: 120s
    sending_queue:
      enabled: true
      num_consumers: 10
      queue_size: 50 # num_seconds * requests_per_second / requests_per_batch

extensions:
  health_check:
  pprof:
    endpoint: :1777
  zpages:
    endpoint: :25679

processors:
  batch:
    timeout: 5s

receivers:
  otlp:
    protocols:
      grpc:
        endpoint: ${env:MY_POD_IP}:4317
      http:
        endpoint: ${env:MY_POD_IP}:4318

service:
  extensions: [pprof, zpages, health_check]
  pipelines:
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [debug, otlp]
