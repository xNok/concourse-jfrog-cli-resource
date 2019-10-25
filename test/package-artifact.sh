#!/bin/bash

if [ ! "$BASH_VERSION" ] ; then
    echo "Please use bash to run this script: ($0)" 1>&2
    exit 1
fi

# execute script from its destination directory.
REPO=$(dirname $(dirname $(realpath ${BASH_SOURCE[0]})))
DESTINATION_OUT=${REPO}/.tmp/out

# create destination directory if not exist
mkdir -p ${DESTINATION_OUT}/artifact
cd ${DESTINATION_OUT}
rm artifact/* -rf

# create version
VERSION=$(echo $(date +'%s'))

# create artifact
echo "hello world" > README.md
tar czf artifact/$ARTFY_ARTIFACT_ID-$VERSION.tar.gz README.md
rm README.md

# create version
echo ${VERSION} > artifact/version

echo $(pwgen 40 1) > ../revision

# create build
if [[ -f build ]]; then
  BUILD_NUMBER=$(cat build | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
else
  BUILD_NUMBER=0
fi

((BUILD_NUMBER++))

echo $BUILD_NUMBER > build 
export BUILD_ID=${BUILD_NUMBER}

# create evidence
template="{\"timestamp\":\"$(echo $VERSION)\",\"produit\":\"poc\",\"composant\":\"poc-artifact\",\"branche\":\"master\",\"statut\":\"OK\",\"metriques\":[{\"nom\":\"couverture\",\"valeur\":\"100.0\",\"cible\":\"80\",\"statut\":\"OK\"},{\"nom\":\"fiabilite\",\"valeur\":\"A\",\"cible\":\"A\",\"statut\":\"OK\"},{\"nom\":\"securite\",\"valeur\":\"A\",\"cible\":\"A\",\"statut\":\"OK\"},{\"nom\":\"maintenabilite\",\"valeur\":\"A\",\"cible\":\"A\",\"statut\":\"OK\"}]}"

jq -n ${template} > artifact/$ARTFY_ARTIFACT_ID-$VERSION-evidence.json

# create _remote.repositories to test file exclusion
touch artifact/_remote.repositories 