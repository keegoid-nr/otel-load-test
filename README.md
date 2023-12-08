# OTel Load Test

## Components

- [docker](./docker/README.md) - Utilizes `docker compose` to create two containers: `docker-otel-load-test-1` and `docker-otel-collector-1`.
- [kubernetes](./kubernetes/README.md) - Creates a cluster in EKS and deploys the collector and Go app as daemonsets.
- [go](./go/) - Generates random metrics and sends them to the collector.
- [python](./python/) - Generates random metrics and sends them to the collector. The Python app has a problem sending all metrics to the collector for some reason.
