#!/usr/bin/env Rscript

library(synapser)
library(data.table)

args <- commandArgs(trailingOnly = TRUE)
FILES_TABLE <- args[1] # syn16858331, unlikely to change
RESOURCE_TABLE <- args[2] # syn26450069, may still move around
STUDY_RESOURCE_TABLE <- args[3] # different dev/test (syn26452699) and production entities

# Make sure authToken is in environment
synLogin(authToken = Sys.getenv("SYNAPSE_AUTH_TOKEN"))

# Retrieve Portal - Files table ------------------------------------------------#
# individualID = String
# specimenID = StringList
# modelSystemName = String
files <- synTableQuery(sprintf("SELECT studyId, UNNEST(specimenID) AS specimenID, individualID, modelSystemName 
                               FROM %s WHERE studyId <> '' OR individualID <> '' OR specimenID <> '' OR modelSystemName <> ''", FILES_TABLE))
meta <- fread(files$filepath)

# Slightly more reshaping given that
# individualID and modelSystemName can look like "iHSC1-lambda, STS26T, S462, S462TY, ST8814"
# so make into list and unnest (which we already were able to do with specimenID on the SQL query side)
meta[, individualID := strsplit(individualID, ", ?")]
meta[, modelSystemName := strsplit(modelSystemName, ", ?")]
metaL <- meta[, .(individualID = as.character(unlist(specimenID)), 
                  modelSystemName= as.character(unlist(modelSystemName))),
              by = list(ROW_ID, ROW_VERSION, ROW_ETAG, studyId, specimenID)]

# Retrieve Resources table -----------------------------------------------------#
# Ignore anything but 'Cell Line' and 'Animal Model' for now
# For card display, should limit selected columns to just what's needed
resources_ <- synTableQuery(sprintf("SELECT resourceId, resourceName, 
                           resourceType, UNNEST(synonyms) AS synonyms,
                           rrid, description FROM %s WHERE resourceType IN ('Cell Line', 'Animal Model')", RESOURCE_TABLE))
resources <- fread(resources_$filepath)
resources[, synonyms := fifelse(synonyms == "", NA_character_, synonyms)]
resources[, ROW_ID := NULL]
resources[, ROW_VERSION := NULL]

# Join -------------------------------------------------------------------------#
# If files meta were clean, cell lines and animal models should **reliably** be in modelSystemName
# However, where the annotations are can be inconsistent 
# (just because modelSystemName is there doesn't mean it will be used)
# So we match names within individualID, specimenID, modelSystemName to names in Resource
# This script's job IS NOT TO REMEDIATE usage of modelSystemName
triMatch <- function(li1, li2, li3) {
  # Technically doesn't matter in which column the resource name appears
  master_list <- na.omit(unique(unlist(c(li1, li2, li3))))
  selected <- resources[resourceName %in% master_list | synonyms %in% master_list, ]
  return(selected)
}

result <- metaL[, (resourceId = triMatch(individualID, specimenID, modelSystemName)), by = studyId]
# Repackage synonyms as simple comma-sep string
result_export <- copy(result)
result_export[, synonyms := fifelse(is.na(synonyms), "", synonyms)]
result_export <- result_export[, .(synonyms = paste(synonyms, collapse = ", ")), by = setdiff(names(result_export), "synonyms")]

# Upload -----------------------------------------------------------------------#

# Remove old rows as way to rebuild table without making new table entity
old <- synTableQuery(sprintf("select * from %s", STUDY_RESOURCE_TABLE))
deleted <- synDelete(old)

# Follows original resource schema for the most part
cols <- list(
  Column(name = "studyId", columnType = "STRING", maximumSize = 36),
  Column(name = "resourceId", columnType = "STRING", maximumSize = 36),
  Column(name = "resourceName", columnType = "STRING", maximumSize = 100),
  Column(name = "resourceType", columnType = "STRING", maximumSize = 15),
  Column(name = "rrid", columnType = "STRING"),
  Column(name = "description", columnType = "LARGETEXT"),
  Column(name = "synonyms", columnType = "STRING", maximumSize = 100))

schema <- Schema(name = "STUDY_RESOURCE", columns = cols, parent = "syn26452506")
table_upload <- Table(schema, result_export)
table_upload <- synStore(table_upload)

