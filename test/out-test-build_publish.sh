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

# package artifact
source $TEST_DIR/package-artifact.sh

jq -n "
{
  source: {
    host: \"${ARTFY_URL}\",
    api_key: \"${ARTFY_API_KEY}\",
    repository_id: \"${ARTFY_REPO_ID}\",
    group_id: \"${ARTFY_GROUP_ID}\",
    artifact_id: \"${ARTFY_ARTIFACT_ID}\"
  },
  params: {
    path: \"artifact\",
    build_publish: {
      build_name: \"${PARAM_BUILD_NAME}\",
      add_git: \"${PARAM_GIT_REPO}\",
      env_include: \"ARTFY_*;BUILD_*;ATC_*\",
      env_exclude: \"ARTFY_API_KEY\"}
  }
}
" | tee | $TEST_DIR/../assets/out ${TEST_DIR}/destination | jq .

