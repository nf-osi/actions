# create-table-snapshot
This is a container action to create a snapshot of a table/view. 
See https://python-docs.synapse.org/build/html/index.html?highlight=snapshot#synapseclient.Synapse.create_snapshot_version.
It is intended to be used in scheduled workflows for versioning desired assets. 

### Inputs
- `table`: A synapse table ID
- `comment`: Optional snapshot comment, defaults to "action-snapshot"
- `label`: Optional label for snapshot version, defaults to the date-time of run if not set

### Ouputs
- `version`: The created version reference. Can be passed to other steps in workflow.

### Secrets
- env `SYNAPSE_AUTH_TOKEN`: Should have update scope for the specified `table`. 
