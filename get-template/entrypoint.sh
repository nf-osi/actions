#!/bin/bash
# Use schematic to generate specified manifests
# Note that schematic uses title-case version of labels as class ids, so reference accordingly
# Arg -t accepts one or more templates as comma-delimited string, e.g. "datasetType1,datasetType2" 
# Arg -j is for specifying path to jsonld schema file
# DOES NOT check that config and creds files are present/valid; these should be setup prior to call

while getopts ":t:j:" opt; do
  case $opt in
    t) ts="$OPTARG"
    ;;
    j) jsonld="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    exit 1
    ;;
  esac

  case $OPTARG in
    -*) echo "Option $opt needs a valid argument"
    exit 1
    ;;
  esac
done

IFS=', ' read -r -a templates <<< "$ts"
echo "In: $pwd"
echo "Number of templates given: ${#templates[@]}" 
echo "Schema file: $jsonld" 

schematic init --config config.yml --auth service_account
                   
for i in "${templates[@]}"
do
  echo "Template: $i"
  schematic manifest -c config.yml get -dt $i -t "$i Manifest" --jsonld $jsonld
done
