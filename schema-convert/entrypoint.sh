#!/bin/bash
set -e
 
SCHEMA_CSV=$1
SCHEMA_CSV_PATH="/github/workspace/$SCHEMA_CSV" # using abs path may not be necessary since -w /github/workspace/ ?

schematic schema convert $SCHEMA_CSV_PATH

# By default, name of file will be same except with .jsonld extension
SCHEMA_JSONLD="${SCHEMA_CSV%.csv}.jsonld" 

# https://docs.github.com/en/actions/creating-actions/metadata-syntax-for-github-actions#outputs 
echo "::set-output name=jsonld::$SCHEMA_JSONLD"
