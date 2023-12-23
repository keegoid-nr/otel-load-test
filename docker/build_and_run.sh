#!/bin/bash
# ------------------------------------------------------
# Source, bring down, build, and bring up new containers
#
# Author : Keegan Mullaney
# Company: New Relic
# Website: github.com/keegoid-nr/otel-load-test
# License: Apache 2.0
# ------------------------------------------------------

# Source environment variables
source .env

# Stop all containers
docker-compose down --remove-orphans

# Remove all stopped containers, images, networks, build cache objects, and volumes not in use
docker system prune -af --volumes

# Build the otel-load-test:latest image
docker-compose build --no-cache --force-rm

# Run the containers
docker-compose up
