#!/bin/bash

if [ ! "$BASH_VERSION" ] ; then
    echo "Please do not use sh to run this script ($0), just execute it directly" 1>&2
    exit 1
fi

set -o allexport
source .env
set +o allexport

# execute script from the test directory.
TEST_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

if [[ -f "${TEMP_DIR}/artifact/version" ]] ; then
    VERSION=$(cat ${TEMP_DIR}/artifact/version)
else
    VERSION=""
fi

jq -n "
{
    source: {
        host : \"${ARTFY_URL}\",
        api_key : \"${ARTFY_API_KEY}\",
        repository_id : \"${ARTFY_REPO_ID}\",
        group_id : \"${ARTFY_GROUP_ID}\",
        artifact_id : \"${ARTFY_ARTIFACT_ID}\"
    },
    version: {
        ref: \"$VERSION\"
    }
}
" | tee | $TEST_DIR/../assets/check | jq .
