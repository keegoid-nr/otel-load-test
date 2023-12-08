<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [OTel Load Test](#otel-load-test)
  - [Components](#components)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# OTel Load Test

## Components

- [docker](./docker/README.md) - Utilizes `docker compose` to create two containers: `docker-otel-load-test-1` and `docker-otel-collector-1`.
- [kubernetes](./kubernetes/README.md) - Creates a cluster in EKS and deploys the collector and Go app as daemonsets.
- [go](./go/) - Generates random metrics and sends them to the collector.
- [python](./python/) - Generates random metrics and sends them to the collector. The Python app has a problem sending all metrics to the collector for some reason.
