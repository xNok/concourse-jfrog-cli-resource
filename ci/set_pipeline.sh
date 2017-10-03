#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

ALIAS=${1:-emerald-squad}
CREDENTIALS=${2:-$DIR/params-sample.yml}
PIPELINE_NAME=${3:-artifactory-resource}

echo y | fly -t "${ALIAS}" sp -p "${PIPELINE_NAME}" -c $DIR/pipeline.yml -l "${CREDENTIALS}"
fly -t "$ALIAS" expose-pipeline -p "$PIPELINE_NAME"
