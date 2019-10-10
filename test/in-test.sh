#!/bin/bash

if [ ! "$BASH_VERSION" ] ; then
    echo "Please do not use sh to run this script ($0), just execute it directly" 1>&2
    exit 1
fi

# execute script from its destination directory.
REPO=$(dirname $(dirname $(realpath ${BASH_SOURCE[0]})))
ASSETS=${REPO}/assets
DESTINATION_IN=${REPO}/.tmp/in
LAST_CHECKED_VERSION=${REPO}/.tmp/check/output.json

# package artifact
source ${REPO}/test/check-test.sh

# create destination directory if not exist
mkdir -p ${DESTINATION_IN}/artifact
cd ${DESTINATION_IN}
rm artifact/* -rf


if [[ -f "${LAST_CHECKED_VERSION}" ]] ; then
    VERSION=$(cat ${LAST_CHECKED_VERSION} | jq -r .[-1].ref)
else
    VERSION="-1"
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
    params: {
        qualifiers: [\"evidence\"]
    },
    version: {
        ref: \"${VERSION}\"
    }
}
" | ${ASSETS}/in artifact | jq . | tee  output.json | jq .
