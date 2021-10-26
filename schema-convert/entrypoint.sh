#!/bin/bash
set -e
 
SCHEMA_CSV=$1

schematic schema convert $SCHEMA_CSV

# By default, name of file will be same except with .jsonld extension
SCHEMA_JSONLD="${SCHEMA_CSV%.csv}.jsonld" 

# https://docs.github.com/en/actions/creating-actions/metadata-syntax-for-github-actions#outputs 
echo "::set-output name=jsonld::$SCHEMA_JSONLD"
