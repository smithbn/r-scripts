search_confirm_originations_sql <- paste0("SELECT srch.city as city
,srch.state as state
,srch.country as country
,srch.longitude as longitude
,srch.latitude as latitude
,SUM(srch.searches) as searches
,SUM(srch.confirms) as confirms
FROM (
  SELECT b.city
  ,b.state
  ,b.country
  ,b.longitude
  ,b.latitude
  ,(CASE 
    WHEN event_type = 'FLIGHT_SEARCH'
    THEN 1			
    ELSE NULL
    END) AS searches
  ,(CASE 
    WHEN event_type = 'FLIGHT_CONFIRMATION'
    THEN 1			
    ELSE NULL
    END) AS confirms
  FROM (
    SELECT a.event_type AS event_type
    ,airports.city AS city
    ,airports.state AS state
    ,airports.country AS country
    ,airports.longitude AS longitude
    ,airports.latitude AS latitude
    ,a.profileid
    FROM (
      SELECT *
        FROM [",dest$projectId,":",dest$datasetId,".",dest$tableId,"]
      WHERE event_type = 'FLIGHT_SEARCH'
      OR event_type = 'FLIGHT_CONFIRMATION'
      AND experiment_bucket = 'Exposed'
      AND origin_airport NOT IN (",destination_airports,")
    ) a
    JOIN (
      SELECT city as city
      ,province as state
      ,country as country
      ,iata_faa_code as iata
      ,longitude as longitude
      ,latitude as latitude
      FROM [sojern-bigquery:analytics_dataset.d_airport]
    ) airports ON (airports.iata = a.origin_airport)
  ) b
) srch
GROUP BY city
,state
,country 
,longitude
,latitude;")