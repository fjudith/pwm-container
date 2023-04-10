#!/usr/bin/env bash
set -euo pipefail

source hack/libraries/custom-logger.sh -v

function init_env()
{
    if [ ! -f .env ]
    then
        ewarn 'Environment ".env" file not found'
        ewarn 'Creating using default settings from ".env.example"'
        cp .env.example .env
    fi

    set -o allexport
    source .env
    set +o allexport
    eok "Environment variables initialized from \"${PWD}/.env\""
}

function start_infrastructure()
{
    ENV_FILE=${PWD}/.env
    docker compose --env-file=${ENV_FILE} up \
        --detach \
        --quiet-pull \
        --build \
        --remove-orphans
    eok "Local environment started"
}

init_env
start_infrastructure
