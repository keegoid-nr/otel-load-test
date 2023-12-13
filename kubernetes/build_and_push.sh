#!/bin/bash
# ------------------------------------------------------
# Build and push otel-load-test for OTEL collector.
#
# Author : Keegan Mullaney
# Company: New Relic
# Website: github.com/keegoid-nr/otel-load-test
# License: Apache 2.0
# ------------------------------------------------------

# Retrieve REPOSITORY_NAME and REPOSITORY_NAME from the arguments
REGISTRY_NAME=$1
REPOSITORY_NAME=$2

aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin "${REGISTRY_NAME}"

# Build the Docker image
docker build -t "${REPOSITORY_NAME}" ../go/

# Tag the image
docker tag "${REPOSITORY_NAME}:latest" "${REGISTRY_NAME}/${REPOSITORY_NAME}:latest"

# Push the Docker image
docker push "${REGISTRY_NAME}/${REPOSITORY_NAME}:latest"

echo "$REPOSITORY_NAME container image has been built and pushed to $REGISTRY_NAME/$REPOSITORY_NAME:latest"
