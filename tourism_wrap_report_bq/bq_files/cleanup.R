# Delete the post-impression travel events table and cleanup objects
# --------------------------------------------------------------------
delete_table(project = dest$projectId, dataset = dest$datasetId, table = dest$tableId)
delete_table(project = dest$projectId, dataset = "analytics_dataset", table = "campaign_impressions")