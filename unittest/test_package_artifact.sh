#!/bin/bash

# TEST SETUP
## package under test
source ./assets/package_artefact_util

## Create data for test
tmp_dir=$(mktemp -d -t ci-XXXXXXXXXX)
echo "$tmp_dir" && cd "$tmp_dir"

trap cleanup EXIT

function cleanup()
{
    if [ $? = 0 ]; then
        echo "\e[92m TESTS SUCCESS"
        rm -rf $tmp_dir
    else
        echo "\e[91m TRY AGAIN"

        echo ""

        echo "WANT:"
        echo "$validation"
        echo ""
        echo "GOT:" 
        cat "$tmp_dir/to_validate.txt"
    fi
}

# TEST SUITE package_artefact 1
echo "--- TEST SUIT: Basic cases ---"

function setup()
{
    rm -rf "$tmp_dir" && mkdir "$tmp_dir"
    touch evidence.yml
    touch evidence-asdads.yml
    touch configuration.yml
    touch application.zip
    mkdir subfolder
    touch subfolder/sub-evidence.yml
    touch subfolder/sub-bar.yml

    files=$(find "$tmp_dir" -type f -not -path "$tmp_dir/.git/*" -not -name "version" -not -name "build" -not -name "_remote.repositories" -not -name "config.yaml")

}

artifact_id="test"
version="test"

echo "$files"

## TEST CASE 1
echo "--- TEST CASE 1: binary and evidences"
setup

### GIVEN
package_artifact_testset1='{"bin": "application", "evidences": "evidence"}'
### WHEN
echo_packaging_rules "$package_artifact_testset1" > to_validate.txt
### THEN
validation="Packaging Rules:
   application: {artifact_id}-{version}.packaging
   evidence: {artifact_id}-{version}-{classifier}.packaging"

if [ "$validation" != "$(cat "$tmp_dir/to_validate.txt")" ]; then exit 1; fi

### WHEN
for abs_file in $files; do
    package_artefact "$abs_file" "$artifact_id" "$version" "$tmp_dir"
done
### THEN
validation="./test-test-evidence-asdads.yml
./test-test-evidence.yml
./test-test-sub-evidence.yml
./test-test.zip
./to_validate.txt"

find . -type f > to_validate.txt

if [ "$validation" != "$(cat "$tmp_dir/to_validate.txt")" ]; then exit 1; fi

## TEST CASE 2
echo "--- TEST CASE 2: only binary"
setup

### GIVEN
package_artifact_testset1='{"bin": "application"}'

### WHEN
echo_packaging_rules "$package_artifact_testset1" > to_validate.txt

validation="Packaging Rules:
   application: {artifact_id}-{version}.packaging"
### THEN
if [ "$validation" != "$(cat "$tmp_dir/to_validate.txt")" ]; then exit 1; fi

### WHEN
for abs_file in $files; do
    package_artefact "$abs_file" "$artifact_id" "$version" "$tmp_dir"
done
### THEN
validation="./test-test.zip
./to_validate.txt"

find . -type f > to_validate.txt

if [ "$validation" != "$(cat "$tmp_dir/to_validate.txt")" ]; then exit 1; fi

## TEST CASE 3

echo "--- TEST CASE 3: noting"
setup

### GIVEN
package_artifact_testset1=''
### WHEN
echo_packaging_rules "$package_artifact_testset1" > to_validate.txt
### THEN
validation="Packaging Rules:"

if [ "$validation" != "$(cat "$tmp_dir/to_validate.txt")" ]; then exit 1; fi

### WHEN
for abs_file in $files; do
    package_artefact "$abs_file" "$artifact_id" "$version" "$tmp_dir"
done
### THEN
validation="./to_validate.txt"

find . -type f > to_validate.txt

if [ "$validation" != "$(cat "$tmp_dir/to_validate.txt")" ]; then exit 1; fi
