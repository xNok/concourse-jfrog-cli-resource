#!/bin/bash
set -x

request=$1
user=$2

user=$2
if [[ -z $user || -z $request ]]; then
    echo "Required arguments: <request file> <docker user>"
    exit 1
fi

# Interpolating the json in bash:
# (. ./test/.env && eval "echo \"$(cat $request | sed 's/"/\\"/g' )\"")

(. ./test/.env && eval "echo \"$(cat $request | sed 's/"/\\"/g' )\"") | docker run --rm -i \
-v "${pwd}/test/tmp:/tmp" \
$user/artifactory-resource /opt/resource/out /tmp