# Kubernetes

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Prerequisites:](#prerequisites)
- [Setup](#setup)
- [Install](#install)
- [Components](#components)
  - [main.tf](#maintf)
  - [configmap.tf](#configmaptf)
  - [daemonset.tf](#daemonsettf)
  - [namespace.tf](#namespacetf)
  - [service.tf](#servicetf)
  - [variables.tf](#variablestf)
- [Notes:](#notes)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Prerequisites:

- Go 1.21
- Terraform 1.5.7
- AWS CLI 2.11.21

## Setup

Create a `terraform.tfvars` file to store variable values for Terraform to use.

```sh
NEW_RELIC_API_KEY=<your_key>
LOG_EXPORTER_VERBOSITY=basic # basic or detailed
OTEL_CONFIG_COMPLEXITY=complex # simple or complex
RUNTIME=go # go or python
```

## Install

```sh
terraform validate .
terraform plan -out tfplan
terraform apply "tfplan"
```

## Components

### main.tf

Sets the providers, local variables, outputs, and eks module. At the bottom of the file, we describe how to run the [build_and_push.sh](./build_and_push.sh) file passing in the Terraform outputs as inputs to the script.

### configmap.tf

Defines the otel-config.yaml in Kubernetes.

### daemonset.tf

Defines the otel_collector and otel_load_test container spec.

### namespace.tf

Sets the namespace.

### service.tf

Defines the service in the namespace.

### variables.tf

Defines the variables. Create your own `terraform.tfvars` to set values for variables. **Do not commit the tfvars file**.

## Notes:

- **Endpoint Configuration**: The `OTLPMetricExporter` is configured to send metrics to an OpenTelemetry Collector. Replace `"localhost:4317"` with the address of your collector within the Kubernetes cluster.
- **Metric Generation**: This script uses a simple loop to generate random metric values. You can adjust the frequency and complexity of these metrics based on your testing needs.
- **Kubernetes Deployment**: When deploying this application in Kubernetes, we package it in a container and define the necessary Kubernetes resources (like a DaemonSet) for its deployment.
