#!/bin/bash

if [ ! "$BASH_VERSION" ] ; then
    echo "Please use bash to run this script: ($0)" 1>&2
    exit 1
fi

# execute script from its destination directory.
REPO=$(dirname $(dirname $(realpath ${BASH_SOURCE[0]})))
ASSETS=${REPO}/assets

artifact_id=${ARTFY_ARTIFACT_ID}
payload=$(mktemp -t payload.XXXXXX)

jq -n '{
  source: {
    host: "'${ARTFY_URL}'",
    api_key: "'${ARTFY_API_KEY}'",
    repository_id: "'${ARTFY_REPO_ID}'",
    group_id: "'${ARTFY_GROUP_ID}'",
    artifact_id: "'${ARTFY_ARTIFACT_ID}'"
  },
  params: {
    path: "artifact",
    build_publish: {
      git_url: "'${PARAM_GIT_REPO}'",
      git_rev: "'${PARAM_GIT_REV}'",
      env_include: "ARTFY|BUILD|ATC",
      env_exclude: "ARTFY_API_KEY"
    }
  }
}
' > ${payload}

source ${ASSETS}/build_util

add_artifact patate frite $(pwgen 40 1) $(pwgen 64 1) $(pwgen 32 1)
add_artifact patate douce $(pwgen 40 1) $(pwgen 64 1) $(pwgen 32 1)
add_artifact patate chips $(pwgen 40 1) $(pwgen 64 1) $(pwgen 32 1)

cat ${BUILD_INFO} | jq .