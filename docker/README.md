<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Docker](#docker)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Docker

This directory contains the config files to run either the Go or Python otel-load-test app and the collector.

If the collector is not configured correctly, it may not export metrics fast enough. In that case, you'll see an error like the following for the Go app:

```log
otel-collector-1  | 2023-12-07T21:06:16.517Z    error   exporterhelper/queue_sender.go:229      Dropping data because sending_queue is full. Try increasing queue_size. {"kind": "exporter", "data_type": "metrics", "name": "otlp", "dropped_items": 104}
otel-collector-1  | go.opentelemetry.io/collector/exporter/exporterhelper.(*queueSender).send
otel-collector-1  |     go.opentelemetry.io/collector/exporter@v0.90.1/exporterhelper/queue_sender.go:229
otel-collector-1  | go.opentelemetry.io/collector/exporter/exporterhelper.(*baseExporter).send
otel-collector-1  |     go.opentelemetry.io/collector/exporter@v0.90.1/exporterhelper/common.go:193
otel-collector-1  | go.opentelemetry.io/collector/exporter/exporterhelper.NewMetricsExporter.func1
otel-collector-1  |     go.opentelemetry.io/collector/exporter@v0.90.1/exporterhelper/metrics.go:98
otel-collector-1  | go.opentelemetry.io/collector/consumer.ConsumeMetricsFunc.ConsumeMetrics
otel-collector-1  |     go.opentelemetry.io/collector/consumer@v0.90.1/metrics.go:25
otel-collector-1  | go.opentelemetry.io/collector/internal/fanoutconsumer.(*metricsConsumer).ConsumeMetrics
otel-collector-1  |     go.opentelemetry.io/collector@v0.90.1/internal/fanoutconsumer/metrics.go:73
otel-collector-1  | go.opentelemetry.io/collector/processor/batchprocessor.(*batchMetrics).export
otel-collector-1  |     go.opentelemetry.io/collector/processor/batchprocessor@v0.90.1/batch_processor.go:442
otel-collector-1  | go.opentelemetry.io/collector/processor/batchprocessor.(*shard).sendItems
otel-collector-1  |     go.opentelemetry.io/collector/processor/batchprocessor@v0.90.1/batch_processor.go:256
otel-collector-1  | go.opentelemetry.io/collector/processor/batchprocessor.(*shard).processItem
otel-collector-1  |     go.opentelemetry.io/collector/processor/batchprocessor@v0.90.1/batch_processor.go:230
otel-collector-1  | go.opentelemetry.io/collector/processor/batchprocessor.(*shard).start
otel-collector-1  |     go.opentelemetry.io/collector/processor/batchprocessor@v0.90.1/batch_processor.go:215
```
