#!/bin/bash

# Intended to be used in CI, this script preps schematic auth in a specific manner:
# 1) Only allows Synapse auth with authtoken.
# 2) Only allows Google API auth with service token.

# -a takes the Synapse authoken string. In workflows, this should be passed as a secret.
# -s takes the Google API service creds JSON string. In workflows, this should be passed as a secret.

while getopts ":a:s:" opt; do
  case $opt in
    a) authtoken="$OPTARG"
    ;;
    s) servicekey="$OPTARG"
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

# Furnish appropriate .synapseConfig file
# Schematic does not take auth as CLI parameter and requires it be in config.yml.
sed "s/MY_AUTHTOKEN/${authtoken}/" .synapseConfig > $GITHUB_WORKSPACE/.synapseConfig

# Furnish appropriate creds.json file
# Schematic/GCP client does not take creds as CLI parameter and requires the .json file.
echo $servicekey > $GITHUB_WORKSPACE/creds.json

# Finally, furnish workspace with config file
mv config.yml $GITHUB_WORKSPACE/config.yml
