#!/bin/bash

# ensure bash
if [ ! "$BASH_VERSION" ] ; then
    echo "Please do not use sh to run this script ($0), just execute it directly" 1>&2
    exit 1
fi

set -o allexport
source .env
set +o allexport

# execute script in it's directory
CURRENT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd $CURRENT_DIR

# create version
VERSION=$(echo $(date +'%s'))

if [[ -d destination ]] ; then
  rm destination -rf
fi

mkdir -p destination/artifact

# create artifact
echo "hello world" > README.md
cp README.md destination/artifact/README.md
rm README.md

# create version
echo $VERSION > destination/artifact/version

# create build
if [[ -f build ]]; then
  BUILD_NUMBER=$(cat build | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
else
  BUILD_NUMBER=0
fi
BUILD_NUMBER=$((BUILD_NUMBER + 1))

echo $BUILD_NUMBER > build 
# echo $BUILD_NUMBER > destination/artifact/build
# echo $BUILD_NUMBER > destination/custom_build_file
export BUILD_ID=${BUILD_NUMBER}

# create evidence
jq -n -c '{"produit":"poc","composant":"poc-artifact","branche":"master","statut":"OK","metriques":[{"nom":"couverture","valeur":"100.0","cible":"80","statut":"OK"},{"nom":"fiabilite","valeur":"A","cible":"A","statut":"OK"},{"nom":"securite","valeur":"A","cible":"A","statut":"OK"},{"nom":"maintenabilite","valeur":"A","cible":"A","statut":"OK"}]}' \
> destination/artifact/evidence.json

# create _remote.repositories to test file exclusion
touch destination/artifact/_remote.repositories