#!/usr/bin/env bash
set -euo pipefail

source make/libraries/custom-logger.sh -v

ORGANIZATION=${ORGANIZATION:-'fjudith'}
PROJECT_NAME=${PROJECT_NAME:-'pwm'}

docker image build \
    --build-arg="APP_VERSION=$(cat VERSION)" \
    --tag oci.local/${ORGANIZATION}/${PROJECT_NAME}:alpine \
    ./alpine/

eok "Successfully built Alpine image"

docker image build \
    --build-arg="APP_VERSION=$(cat VERSION)" \
    --tag oci.local/${ORGANIZATION}/${PROJECT_NAME}:debian \
    ./debian/

eok "Successfully built Debian image"