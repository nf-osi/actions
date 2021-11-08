import synapseclient
import sys
import os
from datetime import datetime

syn = synapseclient.Synapse()

## log in with SYNAPSE_AUTH_TOKEN env variable
syn.login()

target_table = sys.argv[1]
target_comment = sys.argv[2]
target_label = datetime.now() if sys.argv[3] == '' else sys.arg[3]
print(f"Target table: {target_table}")

version = syn.create_snapshot_version(table = target_table, comment = target_comment, label = target_label)
print("--- has been updated to ---")
print(f"::set-output name=version::{target_table}.{version}")
print(f"with version comment: {target_comment}")
print(f"with version label: {target_label}")
