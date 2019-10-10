#!/bin/bash

if [ ! "$BASH_VERSION" ] ; then
    echo "Please do not use sh to run this script ($0), just execute it directly" 1>&2
    exit 1
fi

# execute script from its destination directory.
REPO=$(dirname $(dirname $(realpath ${BASH_SOURCE[0]})))
ASSETS=${REPO}/assets
DESTINATION_CHECK=${REPO}/.tmp/check

# create .tmp sub-directory if not exist
mkdir -p ${DESTINATION_CHECK}
cd ${DESTINATION_CHECK}

if [[ -f "output.json" ]] ; then
    VERSION=$(cat output.json | jq -r .[].ref)
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
        ref: \"${VERSION}\"
    }
}
" | ${ASSETS}/check | jq . | tee output.json | jq .
