unique_travelers_sql <- paste0("SELECT count(DISTINCT CASE 
             WHEN c.experiment_bucket = 'Exposed'
             AND (
               c.event_type = 'HOTEL_SEARCH'
               OR c.event_type = 'FLIGHT_SEARCH'
               OR c.event_type = 'VACATION_SEARCH'
               OR c.event_type = 'CAR_SEARCH'
             )
             THEN c.profileid
             ELSE NULL
             END) AS total_unique_exposed_searchers
,count(DISTINCT CASE 
       WHEN c.experiment_bucket = 'Control'
       AND (
         c.event_type = 'HOTEL_SEARCH'
         OR c.event_type = 'FLIGHT_SEARCH'
         OR c.event_type = 'VACATION_SEARCH'
         OR c.event_type = 'CAR_SEARCH'
       )
       THEN c.profileid
       ELSE NULL
       END) AS total_unique_control_searchers
,count(DISTINCT CASE 
       WHEN c.experiment_bucket = 'Exposed'
       AND (
         c.event_type = 'HOTEL_CONFIRMATION'
         OR c.event_type = 'FLIGHT_CONFIRMATION'
         OR c.event_type = 'VACATION_CONFIRMATION'
         OR c.event_type = 'CAR_CONFIRMATION'
       )
       THEN c.profileid
       ELSE NULL
       END) AS total_unique_exposed_confirmers
,count(DISTINCT CASE 
       WHEN c.experiment_bucket = 'Control'
       AND (
         c.event_type = 'HOTEL_CONFIRMATION'
         OR c.event_type = 'FLIGHT_CONFIRMATION'
         OR c.event_type = 'VACATION_CONFIRMATION'
         OR c.event_type = 'CAR_CONFIRMATION'
       )
       THEN c.profileid
       ELSE NULL
       END) AS total_unique_control_confirmers
FROM (
  SELECT experiment_bucket
  ,profileid
  ,event_type
  FROM [sojern-bigquery:analytics_dataset.test_temp2]
) c;")