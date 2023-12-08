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
docker-compose build --no-cache
docker-compose up
