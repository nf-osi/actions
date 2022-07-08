#!/bin/bash

# This script sets up schematic auth in a strict manner:
# 1) Only allows Synapse auth with auth token. Uses this to create `.synapseConfig`.
# 2) Only allows Google API auth with service token. Uses this to create `creds.json`. 
# In workflows, these should be passed in as secrets.

# Furnish with .synapseConfig file if given
# Schematic does not take auth as CLI parameter and requires it be in config.yml.
sed "s/MY_AUTHTOKEN/$1/" $GITHUB_ACTION_PATH/.synapseConfig > $GITHUB_WORKSPACE/.synapseConfig

# Furnish appropriate creds.json file if given
# Schematic/GCP client does not take creds as CLI parameter and requires the .json file.
echo $2 | base64 -d > $GITHUB_WORKSPACE/creds.json


