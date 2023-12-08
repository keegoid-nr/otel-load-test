#!/bin/bash
# ------------------------------------------------------
# Build and push otel-load-test for OTEL collector.
#
# Author : Keegan Mullaney
# Company: New Relic
# Website: github.com/keegoid-nr/otel-load-test
# License: Apache 2.0
# ------------------------------------------------------

# Retrieve CONTAINER_REPOSITORY and CONTAINER_REPOSITORY from the arguments
CONTAINER_REGISTRY=$1
CONTAINER_REPOSITORY=$2

aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin "${CONTAINER_REGISTRY}"

# Build the Docker image
docker build -t "${CONTAINER_REPOSITORY}" ../go/

# Tag the image
docker tag "${CONTAINER_REPOSITORY}:latest" "${CONTAINER_REGISTRY}/${CONTAINER_REPOSITORY}:latest"

# Push the Docker image
docker push "${CONTAINER_REGISTRY}/${CONTAINER_REPOSITORY}:latest"

echo "$CONTAINER_REPOSITORY container image has been built and pushed to $CONTAINER_REGISTRY/$CONTAINER_REPOSITORY:latest"
