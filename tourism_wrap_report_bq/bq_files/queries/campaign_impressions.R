campaign_impressions_sql <- paste0("SELECT
DATE(TIMESTAMP(event_time)) AS impression_date,
TIMESTAMP(event_time) AS timestamp,
creative_name AS creative_name,
user_id AS dmp_user_id,
CASE WHEN creative_name CONTAINS 'psa' THEN 'Control' ELSE 'Exposed' END AS experiment_bucket
FROM (
  SELECT
  dbm_view.event_time AS event_time,
  dbm_creative.common_data.name AS creative_name,
  dbm_view.dmp_user_id AS user_id,
  COUNT(*)
  FROM (
    SELECT
    common_data.id,
    common_data.name
    FROM (TABLE_DATE_RANGE(dbm_dataset.dbm_creative, TIMESTAMP('",start_date,"'), TIMESTAMP('",end_date,"')))) AS dbm_creative
  JOIN EACH (
    SELECT
    creative_id,
    event_time,
    dmp_user_id,
    event_type,
    insertion_order_id
    FROM (TABLE_DATE_RANGE(dbm_events_do_not_use.dbm_view, TIMESTAMP('",start_date,"'), TIMESTAMP('",end_date,"')))
     WHERE insertion_order_id IN (",insertion_order_id,")
           AND event_type = 'view') AS dbm_view
  ON
  dbm_creative.common_data.id = dbm_view.creative_id
  GROUP BY
  event_time,
  creative_name,
  user_id ) final_imp_data;")