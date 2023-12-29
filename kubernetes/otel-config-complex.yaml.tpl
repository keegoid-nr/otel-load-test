connectors:
  forward/metrics/main: null
  routing/metrics:
    table:
    - pipelines:
      - metrics/export_newrelic
      statement: route()

exporters:
  debug:
    verbosity: basic
  otlp/newrelic:
    endpoint: "https://otlp.nr-data.net:4317"
    compression: gzip
    sending_queue:
      queue_size: 50 # num_seconds * requests_per_second / requests_per_batch
      # num_consumers: 10
    headers:
      "api-key": ${NEW_RELIC_API_KEY}
    # retry_on_failure:
    #   enabled: true
    #   initial_interval: 1s
    #   max_interval: 10s
    #   max_elapsed_time: 120s

extensions:
  health_check: null
  pprof:
    endpoint: :1777
  zpages:
    endpoint: :25679

processors:
  batch:
    send_batch_max_size: 4000
    send_batch_size: 4000
    # timeout: 5s
  batch/split:
    send_batch_max_size: 1
    send_batch_size: 0
    timeout: 0
  cumulativetodelta:
    initial_value: drop
    max_staleness: 20m
  filter/cilium_hubble:
    error_mode: ignore
    metrics:
      datapoint:
      - metric.name == "hubble_flows_to_world_total" and attributes["verdict"] ==
        "FORWARDED"
  filter/kubernetes:
    metrics:
      metric:
      - IsMatch(name, "^((k8s\\.((pod)|(node)))|container)\\.memory\\.(major_)?page_faults$")
  memory_limiter:
    check_interval: 1s
    limit_mib: 462
  resource/node_name:
    attributes:
    - action: upsert
      key: k8s.node.name
      value: ${K8S_NODE_NAME}
  resource/service_attributes_from_k8s_attributes:
    attributes:
    - action: upsert
      from_attribute: k8s.pod.annotations.telemetry.confluent.cloud/service.name
      key: service.name
    - action: insert
      from_attribute: physical_cluster_id
      key: service.name
    - action: insert
      from_attribute: k8s.pod.labels.app.kubernetes.io/name
      key: service.name
    - action: insert
      from_attribute: k8s.pod.labels.app
      key: service.name
    - action: insert
      from_attribute: k8s.deployment.name
      key: service.name
    - action: insert
      from_attribute: k8s.statefulset.name
      key: service.name
    - action: insert
      from_attribute: k8s.daemonset.name
      key: service.name
    - action: insert
      from_attribute: k8s.cronjob.name
      key: service.name
    - action: insert
      from_attribute: k8s.container.name
      key: service.name
    - action: insert
      from_attribute: k8s.namespace.name
      key: service.name
    - action: insert
      from_attribute: k8s.pod.name
      key: service.instance.id
    - action: insert
      from_attribute: k8s.pod.uid
      key: service.instance.id
  resourcedetection:
    detectors:
    - env
    - gcp
    - ec2
    override: false
  transform/cilium_hubble:
    metric_statements:
    - context: datapoint
      statements:
      - set(resource.attributes["k8s.namespace.name"], attributes["source"])
      - set(resource.attributes["k8s.pod.name"], "custom-connect-0")
      - delete_key(resource.attributes, "k8s.pod.uid")
  transform/delete_service_name:
    metric_statements:
    - context: resource
      statements:
      - delete_key(attributes, "service.name")
  transform/k8s_attributes:
    metric_statements:
    - context: resource
      statements:
      - set(attributes["k8s.deployment.name"], Concat(["__replicaset__", attributes["k8s.replicaset.name"]],
        "")) where (attributes["k8s.deployment.name"] == nil and attributes["k8s.replicaset.name"]
        != nil)
      - replace_pattern(attributes["k8s.deployment.name"], "^__replicaset__(.*)-[0-9a-zA-Z]+$",
        "$$1")
      - set(attributes["container.image.short_name"], attributes["container.image.name"])
      - replace_pattern(attributes["container.image.short_name"], "(?:[^/]+/)*([^/]+)(?::[^:/]+)?",
        "$$1")
      - replace_pattern(attributes["k8s.pod.annotations.telemetry.confluent.cloud/attributes"],
        "([^:,\\s](?:[^:,]*[^:,\\s])?)", "\"$$1\"") where attributes["k8s.pod.annotations.telemetry.confluent.cloud/attributes"]
        != nil
      - merge_maps(attributes, ParseJSON(Concat(["{", attributes["k8s.pod.annotations.telemetry.confluent.cloud/attributes"],
        "}"], "")), "upsert") where attributes["k8s.pod.annotations.telemetry.confluent.cloud/attributes"]
        != nil
      - delete_key(attributes, "k8s.pod.annotations.telemetry.confluent.cloud/attributes")
        where attributes["k8s.pod.annotations.telemetry.confluent.cloud/attributes"]
        != nil
      - delete_matching_keys(attributes, "^k8s\\.pod\\.(ip|uid)$")
      - delete_matching_keys(attributes, "^k8s\\.(pod|job|node)\\.name$") where attributes["k8s.cronjob.name"]
        != nil
  transform/truncate:
    metric_statements:
    - context: datapoint
      statements:
      - truncate_all(attributes, 4095)
      - truncate_all(resource.attributes, 4095)

receivers:
  otlp:
    protocols:
      grpc:
        endpoint: ${env:MY_POD_IP}:4317
      http:
        endpoint: ${env:MY_POD_IP}:4318

service:
  extensions:
  - pprof
  - zpages
  - health_check
  telemetry:
    logs:
      development: false
      encoding: json
      level: INFO
    metrics:
      address: :28888
    resource:
      k8s.container.name: ${K8S_CONTAINER_NAME}
      k8s.namespace.name: ${K8S_NAMESPACE_NAME}
      k8s.node.name: ${K8S_NODE_NAME}
      k8s.pod.name: ${K8S_POD_NAME}
      service.name: otel-load-test
      service.namespace: otel
      service.version: 0.1.0
  pipelines:
    metrics:
      exporters:
      - routing/metrics
      - debug
      processors:
      - memory_limiter
      - filter/kubernetes
      - transform/k8s_attributes
      - resource/node_name
      - resourcedetection
      - resource/service_attributes_from_k8s_attributes
      - cumulativetodelta
      - transform/truncate
      - batch
      receivers:
      - forward/metrics/main
    metrics/export_newrelic:
      exporters:
      - otlp/newrelic
      receivers:
      - routing/metrics
    metrics/otlp:
      exporters:
      - forward/metrics/main
      receivers:
      - otlp
