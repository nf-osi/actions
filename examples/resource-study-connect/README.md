# resource-study-connect workflow

## Summary
- creates a table bridging **studies** and **resources** with minimal information needed for the **card** components on study info page

### Main (public) output
- https://www.synapse.org/#!Synapse:syn26461958/tables/

## Variant notes
- test version `resource-study-connect-test.yml` only has manual trigger, is used for testing changes and for debug
- scheduled version is the deployment version `resource-study-connect-scheduled.yml`

## Jobs Description
- rebuilds a table with `studyId` and resources/selected resource attributes by join of the respective tables; actually just uses [nf-osi/actions/connect-study-resource](https://github.com/nf-osi/actions/tree/main/connect-study-resource)
- versions the new table; actually just uses [nf-osi/actions/create-table-snapshot](https://github.com/nf-osi/actions/tree/main/create-table-snapshot)

## Periodic Review
- cron scheduling; right now scheduled approximately biweekly 
- add/remove columns if card design changes 
