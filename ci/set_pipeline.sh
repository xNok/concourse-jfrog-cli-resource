#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

ALIAS=${1:-emerald-squad}
PIPELINE_NAME=${2:-artifactory-resource}

fly -t "${ALIAS}" sp -n -p "${PIPELINE_NAME}" -c $DIR/pipeline.yml
fly -t "${ALIAS}" up -p "$PIPELINE_NAME"
