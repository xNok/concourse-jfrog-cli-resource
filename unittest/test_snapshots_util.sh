#!/bin/bash

# TEST SETUP
## package under test
source ./assets/snapshots_util

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


# TEST SUITE rename_snapshots_artefact 1
echo "--- TEST SUIT: rename_snapshots_artefact ---"

function setup()
{
    rm -rf "$tmp_dir" && mkdir "$tmp_dir"
    echo "demo-application-java-3e7f378-20200213.153741-3.jar" > demo-application-java-3e7f378-20200213.153741-3.jar
    echo "demo-application-java-3e7f378-20200213.153741-3-testresult.tar" > demo-application-java-3e7f378-20200213.153741-3-testresult.tar
    echo "demo-application-java-3e7f378-20200213.153741-3.pom" > demo-application-java-3e7f378-20200213.153741-3.pom
    echo "demo-application-java-3e7f378-20200213.153527-1.jar" > demo-application-java-3e7f378-20200213.153527-1.jar
    echo "demo-application-java-3e7f378-20200213.153549-2.jar" > demo-application-java-3e7f378-20200213.153549-2.jar
    echo "demo-application-java-3e7f378-20200213.153741-3-testsResults.tar.gz" > demo-application-java-3e7f378-20200213.153741-3-testsResults.tar.gz
    echo "demo-application-java-3e7f378-20200213.153527-1.pom" > demo-application-java-3e7f378-20200213.153527-1.pom
    echo "demo-application-java-3e7f378-20200213.153549-2.pom" > demo-application-java-3e7f378-20200213.153549-2.pom

    echo "SETUP:"
    find "$tmp_dir"

}

setup

qualifiers_param=( "testresult" "testsResults" )

rename_snapshots_artefact "$tmp_dir"

validation="demo-application-java-3e7f378-20200213.153741-3-testresult.tar
demo-application-java-3e7f378-20200213.153741-3-testsResults.tar.gz
demo-application-java-3e7f378-20200213.153741-3.jar
demo-application-java-3e7f378-20200213.153741-3.pom"

cat $(find "$tmp_dir" -type f) >  to_validate.txt

if [ "$validation" != "$(cat "$tmp_dir/to_validate.txt")" ]; then exit 1; fi


# TEST SUITE rename_snapshots_artefact 2
echo "--- TEST SUIT: rename_snapshots_artefact and filter ---"

setup

qualifiers_param=( )

rename_snapshots_artefact "$tmp_dir"

validation="demo-application-java-3e7f378-20200213.153741-3.jar
demo-application-java-3e7f378-20200213.153741-3.pom"

cat $(find "$tmp_dir" -type f) >  to_validate.txt

if [ "$validation" != "$(cat "$tmp_dir/to_validate.txt")" ]; then exit 1; fi