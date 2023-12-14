#!/bin/bash
# ------------------------------------------------------
# Source, bring down, build, and bring up new containers
#
# Author : Keegan Mullaney
# Company: New Relic
# Website: github.com/keegoid-nr/otel-load-test
# License: Apache 2.0
# ------------------------------------------------------

source .env
docker-compose down --remove-orphans
docker container prune -f
docker network prune -f
docker-compose build --no-cache --force-rm -t otel-load-test:latest ../${RUNTIME}/
docker-compose up
